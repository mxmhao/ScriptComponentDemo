#!/bin/zsh

cat /dev/null > ../log.txt
echo "pwd : "`pwd` >> ../log.txt

# 获取有效的pod依赖库
podsArr=(`grep "^[^#]pod" ../Podfile | sed 's/[[:space:]]//g' | awk -F "'|\"" '{print $2}'`)
#echo "podsArr : "$podsArr >> ../log.txt

if ! test -f "ThirdPartyService/Classes/Exclude/build.sh" ; then
    cd ..
#    echo "有cd " >> log.txt
#else
#    echo "no cd" >> ../log.txt
fi


moduleProtocolFiles=(`grep "@ThirdPartyService" -rl --include='*.h' . | awk -F '/' '{print $NF}'`)

#echo "moduleProtocolFiles : "$moduleProtocolFiles >> log.txt

#echo "sh : "$0 >> log.txt
#echo "SRCROOT : "${SRCROOT} >> log.txt
#echo "PODS_ROOT : "${PODS_ROOT} >> log.txt
#echo "\n\n" >> ../log.txt
# 从 set.txt 里面找所需目录的全局变量
#cat /dev/null > "set.txt"
#echo `set` >> "set.txt"

#cd ThirdPartyService/Classes
cd Pods/Headers/Public

ThirdPartyProtocolPath=ThirdPartyProtocol.h

chmod u+w $ThirdPartyProtocolPath

cat /dev/null > $ThirdPartyProtocolPath


echo "#ifndef ThirdPartyProtocol_h" >> $ThirdPartyProtocolPath
echo "#define ThirdPartyProtocol_h\n" >> $ThirdPartyProtocolPath

for file in $moduleProtocolFiles
do
    echo "#import \"$file\"" >> $ThirdPartyProtocolPath
    echo $file
    echo "-----------------------"
done

echo "\n#endif" >> $ThirdPartyProtocolPath

chmod u-w $ThirdPartyProtocolPath
