#!/bin/bash

# Coleta os aliases que referenciam os servidores.
LISTA_PRODS=$(cat ~/.ssh/config | grep -E "prod|fdx" | grep -vE "kettle|redir" | cut -d " " -f 2)
LISTA_IMP=$(cat ~/.ssh/config | grep imp | grep -vE "kettle|redir" | cut -d " " -f 2)

if [ "$1" = "prod" ]; then
   LISTA=$LISTA_PRODS
elif [ "$1" = "imp" ]; then
   LISTA=$LISTA_IMP
else
   echo "Informe se deseja listar prod ou imp"
   echo "Exemplo: ./listarTodasVersoes.sh prod"
   exit 1
fi

# Inicia o SSH Agent
eval $(ssh-agent)

# Adiciona a chave privada ao SSH Agent (Substituir a linha abaixo pelo path onde se encontra a chave)
ssh-add ~/.ssh/id_rsa_paulo

# Comando a ser executado.
COMANDO="/opt/script/listarVersoesRoteirizador.sh"

# Solicitar senha antes de executar o comando sudo
read -s -p "Senha para sudo em $SERVIDOR: " SENHA
echo

for SERVIDOR in $LISTA; do

    echo "Executando '$COMANDO' em $SERVIDOR:"

    # Verifica se o servidor é ptf-gcp-fdx-car
    if [ "$SERVIDOR" = "ptf-gcp-fdx-car" ]; then
        # Caminho direto para o script neste servidor
        SCRIPT_PATH="/opt/scripts/listarVersoesRoteirizador.sh"
    else
        # Encontrar o caminho correto do script listarVersoesRoteirizador.sh usando sudo
        SCRIPT_PATH=$(ssh $SERVIDOR "echo '$SENHA' | sudo -S find /opt/script /opt/scripts -name listarVersoesRoteirizador.sh 2>/dev/null")
    fi
         
    RESULTADO=$(ssh $SERVIDOR "echo '$SENHA' | sudo -S $SCRIPT_PATH")
    echo "$RESULTADO"
    echo "---------------------------------------------------------------------"
done

# Finaliza o SSH Agent após o uso.
ssh-agent -k
