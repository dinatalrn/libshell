#!/bin/bash

THISPATH=$(dirname "$0");

source "$THISPATH/string";

# string
fn_get_filename(){
	echo "$1" | grep -Eo "([^\.\/]+)\." | sed -E "s/\.$//";
}

# string
fn_get_extension(){
	echo "$1" | grep -Eo "([^\.]+)$";
}

cake_routes(){
	BUFFER="<?php \n ";
	BUFFER="$BUFFER \nuse Cake\Core\Plugin; \nuse Cake\Routing\RouteBuilder;";
	BUFFER="$BUFFER \nuse Cake\Routing\Router; \nuse Cake\Routing\Route\DashedRoute; \n";
	BUFFER="$BUFFER \nRouter::defaultRouteClass(DashedRoute::class); \n";
	BUFFER="$BUFFER \nRouter::scope('/', function (RouteBuilder \$routes) { \n";

	for IT in $1/*; do
	  	file=`fn_get_filename $IT`;
	  	if [ ! -s $file ]; then
	  		# echo "$file -> $(hyphenize $file) -> $(underscorize $file) -> $(camelize $file)";
	  		fileUnderscorized=`underscorize $file`;
	  		if [ $file != $fileUnderscorized ]; then
	  			ext=`fn_get_extension $IT`;
	  			if [ ! -s $2 ]; then
	  				mv "$1$file.$ext" "$1$fileUnderscorized.ctp";
		  			# echo "#2 mv $1$file.$ext $1$fileUnderscorized.ctp";
	  			else
		  			echo "# mv $1$file.$ext $1$fileUnderscorized.ctp";
		  		fi
	  		fi
	  		BUFFER="$BUFFER \n\t\$routes->connect('/$(hyphenize $file)', ['controller' => 'Pages', 'action' => '$(camelize $file)']);";
	  	fi
	done

	BUFFER="$BUFFER \n\n\t\$routes->fallbacks(DashedRoute::class); \n";
	BUFFER="$BUFFER \n}); \n";
	BUFFER="$BUFFER \nPlugin::routes(); \n";

	echo -e $BUFFER;
}

cake_controller(){
	BUFFER="<?php ";
	BUFFER="$BUFFER \n\nnamespace App\Controller; \n\nclass PagesController extends AppController{ \n \n";
	BUFFER="$BUFFER \tpublic function initialize(){ \n\t\tparent::initialize(); \n\t} \n \n";
	BUFFER="$BUFFER \tpublic function beforeFilter(\Cake\Event\Event \$event){ \n\t\tparent::beforeFilter(\$event); \n\t} \n";
    
	for IT in $1/*; do
	  	file=`fn_get_filename $IT`;
	  	if [ ! -s $file ]; then
	  		# echo "$file -> $(hyphenize $file) -> $(underscorize $file) -> $(camelize $file)";
	  		BUFFER="$BUFFER \n\tpublic function $(camelize $file)(){} \n";
	  	fi
	done

	BUFFER="$BUFFER \n} \n"

	echo -e $BUFFER;
}

fn_test(){
	cake_routes $1
	cake_controller $1 
}

fn_run(){
	cake_routes $1 true > ./config/routes.php
	cake_controller $1 > ./src/Controller/PagesController.php
}


# read -p "Make your choice!" CHOICE
# case "$CHOICE" in 
case "$1" in 
  	run) 
		fn_run ./src/Template/Pages/;
	;;
 	test|-t)
		fn_test $2;
	;;
	* )
		echo "Invalid call!";
	;;
esac
