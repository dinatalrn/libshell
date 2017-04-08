#!/bin/bash

# echo "MyDirectoryFileLine" | sed -e 's/\([A-Z]\)/-\1/g' -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' -e 's/^-//'

fn_camelize(){
	sed -e 's/[_\-]\(.\)/-\1/g' -e 's/^-//' -e 's/\-[aA]/A/g' -e 's/\-[bB]/B/g' -e 's/\-[cC]/C/g' -e 's/\-[dD]/D/g' -e 's/\-[eE]/E/g' -e 's/\-[fF]/F/g' -e 's/\-[gG]/G/g' -e 's/\-[hH]/H/g' -e 's/\-[iI]/I/g' -e 's/\-[jJ]/J/g' -e 's/\-[kK]/K/g' -e 's/\-[lL]/L/g' -e 's/\-[mM]/M/g' -e 's/\-[nN]/N/g' -e 's/\-[oO]/O/g' -e 's/\-[pP]/P/g' -e 's/\-[qQ]/Q/g' -e 's/\-[rR]/R/g' -e 's/\-[sS]/S/g' -e 's/\-[tT]/T/g' -e 's/\-[uU]/U/g' -e 's/\-[vV]/V/g' -e 's/\-[wW]/W/g' -e 's/\-[xX]/X/g' -e 's/\-[yY]/Y/g' -e 's/\-[zZ]/Z/g' <<< $1
}

fn_lower(){
	sed -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' <<< $1
}

fn_upper(){
	sed -e 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/' <<< $1
}

fn_lower_separeted(){
	sed -e 's/[_\-]/'$1'/g' -e 's/\([A-Z]\)/'$1'\1/g' -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' -e 's/^'$1'//' <<< $2
}

underscorize(){
	# echo "$1" | sed -e 's/\([A-Z]\)/_\1/g' -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' -e 's/^_//'
	if [ $1 ]; then
		fn_lower_separeted '_' $1
	else
		while read data; do
	      	# printf "$data"
			fn_lower_separeted '_' $data
	  	done
	fi
}

hyphenize(){
	# echo "$1" | sed -e 's/\([A-Z]\)/-\1/g' -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' -e 's/^-//'
	if [ $1 ]; then
		fn_lower_separeted '-' $1
	else
		while read data; do
	      	# printf "$data"
			fn_lower_separeted '-' $data
	  	done
	fi
}

camelize(){
	if [ $1 ]; then
		fn_camelize $1
	else
		while read data; do
	      	# printf "$data"
			fn_camelize $data
	  	done
	fi
}

lower(){
	if [ $1 ]; then
		fn_lower $1
	else
		while read data; do
	      	# printf "$data"
			fn_lower $data
	  	done
	fi
}

upper(){
	if [ $1 ]; then
		fn_upper $1
	else
		while read data; do
	      	# printf "$data"
			fn_upper $data
	  	done
	fi
}

fn_get_filename(){
	echo "$1" | grep -Eo "([^\.\/]+)\." | sed -E "s/\.$//";
}

cake_routes(){
	BUFFER='<?php \n ';
	BUFFER="$BUFFER \nuse Cake\Core\Plugin; \nuse Cake\Routing\RouteBuilder; \nuse Cake\Routing\Router; \nuse Cake\Routing\Route\DashedRoute; \n";
	BUFFER="$BUFFER \nRouter::defaultRouteClass(DashedRoute::class); \n";
	BUFFER="$BUFFER \nRouter::scope('/', function (RouteBuilder \$routes) { \n";

	for IT in $1/*; do
	  	file=`fn_get_filename $IT`;
	  	if [ ! -s $file ]; then
	  		# echo "$file -> $(hyphenize $file) -> $(underscorize $file) -> $(camelize $file)";
	  		fileUnderscorized=`underscorize $file`;
	  		if [ $file != $fileUnderscorized ]; then
	  			echo "# mv $1/$file.ctp $1/$fileUnderscorized.ctp";
	  			lower $file;
	  			upper $file;
	  		fi
	  		BUFFER="$BUFFER \n\t\$routes->connect('/$(hyphenize $file)', ['controller' => 'Pages', 'action' => '$(camelize $file)']);";
	  	fi
	done

	BUFFER="$BUFFER \n\n\t\$routes->fallbacks(DashedRoute::class); \n";
	BUFFER="$BUFFER \n}); \n";
	BUFFER="$BUFFER \nPlugin::routes(); \n";

	# echo -e $BUFFER >> $2;
	echo -e $BUFFER;
}

cake_controller(){
	BUFFER='<?php ';
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

	# echo -e $BUFFER >> $2;
	echo -e $BUFFER;
}

fn_test(){
	cake_routes ../../php ./config/routes.php
	cake_controller ../../php ./src/Controller/PagesController.php
}


# read -p "Update $0 (y/N)?" CHOICE
# case "$CHOICE" in 
case "$1" in 
  	test|-t ) 
		# echo "yes";
		fn_test;
	;;
 	* ) 
		$@;
	;;
esac
