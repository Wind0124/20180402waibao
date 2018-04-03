#!/bin/sh

#  ipa-build.sh
#  1，你要打包工程的根目录 2，你要输出的ipa文件目录（你当前用户要有权限） 3,指定的ipa 文件名  参数用空格隔开
#  eg:~
  # ~/Desktop/ipa-build.sh  ~/Documents/workSpace/project   ~/Desktop/project projectName

#!/bin/bash


#参数判断
if [ $# != 5 ] && [ $# != 4 ] && [ $# != 3 ] && [ $# != 2 ]&& [ $# != 1 ];then
echo "Number of params error! Need three params!"
echo "1.path of project(necessary) 2.path of ipa dictionary(necessary) 3.name of ipa file(necessary)"
exit

elif [ ! -d $1 ];then
echo "Params Error!! The 1 param must be a project root dictionary."
exit
elif [ ! -d $2 ];then
echo "Params Error!! The 2 param must be a ipa dictionary."
exit
fi

plistbuddy="/usr/libexec/PlistBuddy"

#工程绝对路径
cd $1
project_path=$(pwd)
#build文件夹路径
build_path=${project_path}/build
commid_id=$3
dist_type=$4
client_name=$5
dft_client_name="Dawson"

#工程配置文件路径
project_name=$(ls | grep xcodeproj | awk -F.xcodeproj '{print $1}')
project_infoplist_path=${project_path}/${project_name}/Info.plist
project_pb_path=${project_path}/${project_name}.xcodeproj/project.pbxproj

#取版本号
bundleShortVersion=$(${plistbuddy} -c "print CFBundleShortVersionString" ${project_infoplist_path})
#取build值
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" ${project_infoplist_path})
#取bundle Identifier前缀
#bundlePrefix=$(/usr/libexec/PlistBuddy -c "print CFBundleIdentifier" `find . -name "*-Info.plist"` | awk -F$ '{print $1}')
bundlePrefix=$(/usr/libexec/PlistBuddy -c "print CFBundleIdentifier" ${project_infoplist_path} | awk -F$ '{print $1}')

codeSign=""

# if [ "$dist_type" != "1" && "$bundleVersion" != "" ];then
#     $plistbuddy -c "Set CFBundleVersion \"${commid_id}\"" ${project_infoplist_path}
# fi
# Adjust
type_name=''
bundleIndentifier="$bundlePrefix"

if [ "$dist_type" != "1" ];then
	if [ "$client_name" == "Dawson" ]; then
		bundleIndentifier="com.mastech.dawson.multimeter"
	fi
	type_name="appstore"
	provision_file="Multimeter_PRD"
	codeSign="iPhone Distribution: Mastech Group, LLC (3GAL63WE84)"
else
	type_name="ent"
	provision_file="myTest2016"
fi

if [ "$dist_type" != "1" ]; then 
	# $plistbuddy -c "Set CFBundleIdentifier \"${bundleIndentifier}\"" $project_infoplist_path
	sed -i "" "s/PROVISIONING_PROFILE = \".*\"/PROVISIONING_PROFILE = \"\"/g" $project_pb_path
	sed -i "" "s/\"PROVISIONING_PROFILE\[sdk=iphoneos\*]\" = \".*\"/\"PROVISIONING_PROFILE\[sdk=iphoneos\*]\" = \"\"/g" $project_pb_path
	sed -i "" "s/PRODUCT_BUNDLE_IDENTIFIER = .*$/PRODUCT_BUNDLE_IDENTIFIER = ${bundleIndentifier};/g" $project_pb_path
	sed -i "" "s/PROVISIONING_PROFILE_SPECIFIER = .*;/PROVISIONING_PROFILE_SPECIFIER = ${provision_file};/g" $project_pb_path
	sed -i "" "s/CODE_SIGN_IDENTITY = \".*\"/CODE_SIGN_IDENTITY = \"${codeSign}\"/g" $project_pb_path
	sed -i "" "s/\"CODE_SIGN_IDENTITY\[sdk=iphoneos\*]\" = \".*\"/\"CODE_SIGN_IDENTITY\[sdk=iphoneos\*]\" = \"${codeSign}\"/g" $project_pb_path
	sed -i "" "s/DEVELOPMENT_TEAM = .*$//g" $project_pb_path
fi

echo $bundleShortVersion:${bundleVersion}:${bundleIndentifier}

cd $project_path

function modifyByClient() {
	#1. plist
	plistFile=${project_path}/${project_name}/Info.plist
    $plistbuddy -c "Set CFBundleDisplayName \"${client_name}\"" ${plistFile}

    #2. strings
    find . -name "InfoPlist.strings" | xargs sed -i "" "s/${dft_client_name}/${client_name}/g"

	#2. Assets
	assetDir="${project_path}/${project_name}/Assets.xcassets"
	clientAppiconDir="$assetDir/AppIcon_${client_name}.appiconset"
	toAppiconDir="$assetDir/AppIcon.appiconset"

	if [ -d $clientAppiconDir ];then	
		if [ -d $toAppiconDir ];then
			rm -rf $toAppiconDir
		fi
		cp -rf $clientAppiconDir $toAppiconDir
	fi
}

function restoreAppiconByClient() {
	assetDir="${project_path}/${project_name}/Assets.xcassets"
	clientAppiconDir="$assetDir/AppIcon_${client_name}.appiconset"
	toAppiconDir="$assetDir/AppIcon.appiconset"

	if [ -d $toAppiconDir ];then	
		mv $toAppiconDir $clientAppiconDir
	fi
}

#1. 清理工程
#删除bulid目录
if  [ -d ${build_path} ];then
rm -rf ${build_path}
fi

modifyByClient

xcodebuild clean || exit

ds=`date +"%Y%m%d%H%M%S"`


#IPA名称
# if [ $# = 3 ];
# then
# ipa_name=$3
# else
ipa_name=${client_name}-${bundleShortVersion}.${type_name}.${ds}.${commid_id}
# fi

echo ${pwd}
#xcrun -sdk iphoneos PackageApplication -v ${build_path}/Release-iphoneos/${project_name}.app  -o ${build_path}/${ipa_name}
archive_dir="$2"/archives/
distr_dir="$2"/distr/

mkdir -p ${archive_dir}
mkdir -p ${distr_dir}

if  [ -d ${archive_path} ] && [ -d ${distr_dir} ];then
#2. 生成archive
echo "xcodebuild archive..."
archive_path=${archive_dir}/${ipa_name}.xcarchive
xcodebuild archive -configuration Release -workspace ${project_path}/${project_name}.xcworkspace  -scheme ${project_name} -archivePath $archive_path
#if [ $# != 0 ];then
#echo "xcodebuild archive error, quitting..."
#exit
#fi
#3. 生成ipa
echo "xcodebuild export ipa..."
xcodebuild -exportArchive -archivePath $archive_path -exportPath $distr_dir/${ipa_name} -exportFormat ipa \
-exportProvisioningProfile ${provision_file}

# restoreAppiconByClient

#if [ $# != 0 ];then
#echo "xcodebuild archive error, quitting..."
#exit
#fi
if [ "$type_name" == "1" ];then
	python distr.py $distr_dir${ipa_name}.ipa
fi

else
echo "mkdir archieve/distr dir error, quiting..."
exit
fi
