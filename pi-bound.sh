#!/bin/bash

# Vamos verificar se o script está sendo executado como root

if [[ $EUID -ne 0 ]] ; then
	echo "Este script deve ser executado como root para continuar, use o comando sudo ou execute-o na conta root"
	exit 1
fi


# Esta função apenas verifica se um comando está presente. Ela é usada para assumir a distro que estamos executando.
is_command() {
	local check_command="$1"

	command -v "${check_command}" > /dev/null 2>&1
}


# Função de instalação principal, que instala o pihole, o unbound e o wget, que usamos para obter alguns arquivos de configuração
pihole_install() {
	if is_command apt-get ; then
		tput setaf 2; echo "Executando distribuição baseada em Debian, continuando..."
		tput setaf 2; echo "Instalação do PiHole começando..."
		curl -sSL https://install.pi-hole.net | bash
	else
		tput setaf 1; echo "Este script foi escrito para rodar em distribuições baseadas em Debian. Removendo..."
		exit 1
	fi
}

dns_install() {
	if is_command apt-get; then
		# Instalar unbound
		tput setaf 2; echo "Atualizando repositórios..."
		apt update -y > /dev/null 
		tput setaf 2; echo "Instalando unbound..." 
	       	apt install unbound -y > /dev/null
	else
		tput setaf 1; echo "Este script foi escrito para rodar em distribuições baseadas em Debian. Removendo..."
		exit 1
	fi
}

configure() {

	# Obtenha o arquivo de lista de root e mova para o diretório de instalação unbound
	tput setaf 2; echo "Obtendo lista de root..."
	wget -O /var/lib/unbound/root.hints https://www.internic.net/domain/named.root 
	
	# Crie um cronjob mensal para obter lista de root
	tput setaf 2; echo "Criando uma tarefa cron para obter dicas de root mensalmente..."
	(crontab -l 2>/dev/null; echo "0 0 1 * * wget -O /var/lib/unbound/root.hints https://www.internic.net/domain/named.root") | crontab -

	# Peça ao usuário o arquivo de configuração IPv4 ou IPv6 para unbound
	read -p "Você quer resolver endereços IPv6 sem restrições? (Y/N)" network
	if $network -eq "N" ; then
		wget -O /etc/unbound/unbound.conf.d/pi-hole.conf https://raw.githubusercontent.com/FG-telecom/Pi-Bound_PiHole_e_Unbound/master/unbound-ipv4 
	else
		wget -O /etc/unbound/unbound.conf.d/pi-hole.conf https://raw.githubusercontent.com/FG-telecom/Pi-Bound_PiHole_e_Unbound/master/unbound-ipv6 
	fi

	# Iniciar e habilitar serviço unbound 
	tput setaf 2; echo "Inicializando Unbound..."
	systemctl start unbound

  	tput setaf 2; echo "Habilitando o Unbound para iniciar na inicialização..."	
	systemctl enable unbound

	# Alterar opções de DNS do pihole
	sed -i 's/PIHOLE_DNS_1=.*$/PIHOLE_DNS_1=127.0.0.1#5335/' "/etc/pihole/setupVars.conf"
	sed -i '/PIHOLE_DNS_2=.*$/d' "/etc/pihole/setupVars.conf"	
}

dns() {

	# Algumas variáveis para testar pesquisas de DNS
	servfail=$(dig sigfail.verteiltesysteme.net @127.0.0.1 -p 5335 | grep SERVFAIL)
	noerror=$(dig sigok.verteiltesysteme.net @127.0.0.1 -p 5335 | grep NOERROR)

	if [[ $servfail == *"SERVFAIL"* ]]; then
		tput setaf 2; echo "Primeiro teste de DNS concluído com sucesso."
	else
		tput setaf 1; echo "A primeira consulta DNS retornou um resultado inesperado."
	fi

	if [[ $noerror == *"NOERROR"* ]]; then
		tput setaf 2; echo "Segundo teste de DNS concluído com sucesso."
	else
		tput setaf 1; echo " A segunda consulta DNS retornou um resultado inesperado."
	fi
}


echo "Este script instalará o pihole, unbound e configurará automaticamente a configuração de DNS do pihole para usar o unbound."
printf "O que você gostaria de fazer? (digite um número e pressione Enter) \n1) Instale o Pihole e o unbound junto com a configuração necessária.\n2) Instale o unbound junto com a configuração necessária.\n"

read answer

if [ "$answer" == "1" ] ;then
	pihole_install
	dns_install
	configure
	dns
else
	dns_install
	configure
	dns
fi
