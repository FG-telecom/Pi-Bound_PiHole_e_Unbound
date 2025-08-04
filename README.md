# O Pi-Bound instala e configura o PiHole e o Unbound para serem o servidor DNS recursivo da sua rede.

Um script simples que instala o PiHole e, em seguida, instala e configura automaticamente o Unbound para ser o servidor DNS do seu pihole.

Este script suporta IPv4 e IPv6. Durante o script, você será solicitado a informar a configuração necessária.

## E se eu já tiver o PiHole instalado?

Durante o script, você será solicitado a instalar o PiHole e o Unbound (opção 1) ou apenas instalar o Unbound junto com a configuração necessária (opção 2).

## Como executar

Execute o seguinte comando no seu Pi para baixar o script:

```
wget -O https://raw.githubusercontent.com/FG-telecom/Pi-Bound_PiHole_e_Unbound/master/pi-bound.sh
```
```
chmod +x pi-bound.sh
```
```
sudo ./pi-bound.sh
```
## Etapas finais

Algumas verificações de DNS são concluídas após a instalação, que serão exibidas na tela dependendo se foram bem-sucedidas ou não. Desde que esses testes não apresentem erros, você pode alterar suas configurações de DHCP para apontar para o IP do seu PI. Caso contrário, aponte seus dispositivos manualmente para usar o seu PI como servidor DNS.



## Créditos

Todos os crédito vão pra o criador do projéto original 
Kentishh https://github.com/kentishh.