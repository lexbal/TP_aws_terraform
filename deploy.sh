#!/bin/bash

DEST_FOLDER=GENERATED/
TEMPLATE_FOLDER=TEMPLATES/
SCRIPTS=SCRIPTS/
INFRA_NAME=group-4
CLIENT_ID=4
GIT_REPO=https://github.com/

cp ${TEMPLATE_FOLDER}provider.template ${DEST_FOLDER}00-provider.tf
cp ${TEMPLATE_FOLDER}network.template new_network

sed -ie "s|<##INFRA_NAME##>|${INFRA_NAME}|g" new_network
sed -ie "s|<##CLIENT_ID##>|${CLIENT_ID}|g" new_network

cat new_network >> ${DEST_FOLDER}01-network.tf
rm new_network
rm new_networke

cp -r ${SCRIPTS} ${DEST_FOLDER}${SCRIPTS}
cp -r ${SCRIPTS}install_web.sh new_script_web

sed -ie "s|<##GIT##>|${GIT_REPO}|g" new_script_web

cp -r new_script_web ${DEST_FOLDER}${SCRIPTS}install_web.sh
rm new_script_web

I=0

while read line
do
	if [ $I -gt 0 ]
	then
		if [ ! -z $line ]
		then
			SG_NAME=$(echo $line | cut -d";" -f1)
			PORT=$(echo $line | cut -d";" -f2)

			FROM_PORT=$(echo $PORT | cut -d"-" -f1)
			TO_PORT=$(echo $PORT | cut -d"-" -f2)

			if [ -z $TO_PORT ]
			then
				TO_PORT=$FROM_PORT
			fi

			PROTOCOL=$(echo $line | cut -d";" -f3)
			TYPE=$(echo $line | cut -d";" -f4)
			SOURCE=$(echo $line | cut -d";" -f5)

			cp ${TEMPLATE_FOLDER}ingress.template new_ingress

			sed -ie "s|<##FROM##>|${FROM_PORT}|g" new_ingress
			sed -ie "s|<##TO##>|${TO_PORT}|g" new_ingress
			sed -ie "s|<##PROTOCOL##>|${PROTOCOL}|g" new_ingress

			if [ "$TYPE" == "SG" ]
			then
				SG_TYPE="security_groups"
				SG_TEMPLATE="aws_security_group.${SOURCE}.id"
			else
				SG_TYPE="cidr_blocks"
				SG_TEMPLATE="${SOURCE}"
			fi

			sed -ie "s|<##TYPE##>|${SG_TYPE}|g" new_ingress
			sed -ie "s|<##TEMPLATE##>|${SG_TEMPLATE}|g" new_ingress

			cat new_ingress >> ${SG_NAME}.ingress
			echo "" >> ${SG_NAME}.ingress
			rm new_ingress
            rm new_ingresse
		fi
	else
		I=1
	fi
done < flow_matrix

for SGROUP in $(ls *.ingress)
do
	GROUP_NAME=$(echo $SGROUP | cut -d"." -f1)
	GEN_FILE="${DEST_FOLDER}${GROUP_NAME}.tf"
	cp ${TEMPLATE_FOLDER}security_group.template $GEN_FILE

	sed -ie "s|<##NAME##>|${GROUP_NAME}|g" $GEN_FILE
    sed -ie "s|<##VPC##>|${INFRA_NAME}|g" $GEN_FILE

	LTOWRITE=$(cat -n ${GEN_FILE} | grep "<##INGRESS##>" | sed 's|\t| |g' | tr -s " " | cut -d" " -f2)

	sed -ie "${LTOWRITE} r ${SGROUP}" $GEN_FILE
	sed -ie "s|<##INGRESS##>||g" $GEN_FILE
    rm ${GEN_FILE}e
	rm $SGROUP
done

I=0

while read line
do
	if [ $I -gt 0 ]
	then
		if [ ! -z $line ]
		then
			NAME=$(echo $line | cut -d";" -f1)
			SUBNET=$(echo $line | cut -d";" -f2)
			USER_DATA=$(echo $line | cut -d";" -f3)
			SGROUP=$(echo $line | cut -d";" -f4)

			cp ${TEMPLATE_FOLDER}instance.template new_instance

			sed -ie "s|<##NAME##>|${NAME}|g" new_instance
			sed -ie "s|<##SUBNET##>|${SUBNET}|g" new_instance

			if [ "$USER_DATA" == "NULL" ]
			then
				sed -ie '/<##USER_DATA##>/d' new_instance
			else
				sed -ie "s|<##USER_DATA##>|${SCRIPTS}${USER_DATA}|g" new_instance
			fi
			sed -ie "s|<##SECURITY_GROUP##>|${SGROUP}|g" new_instance

			mv new_instance ${DEST_FOLDER}${NAME}.tf
            rm new_instancee
		fi
	else
		I=1
	fi
done < instances_matrix
