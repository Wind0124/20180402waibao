#!/bin/sh

# 1. download from the git


# 2. pod update --no-repo-update
#pod update --no-repo-update


#mkdir -p ./Cubicle/ipa-build
# git提交版本号
commit_id=`git log|head -1|awk '{print $2}'|cut -c 1-7`
# 发布类型,是否企业发布
dist_type=1

#厂商名称
client_name="Dawson"
sh ./ipa-build.sh ./ ~/ $commit_id $dist_type $client_name
git reset --hard HEAD


client_name="THD"
sh ./ipa-build.sh ./ ~/ $commit_id $dist_type $client_name
git reset --hard HEAD

client_name="STEREN"
sh ./ipa-build.sh ./ ~/ $commit_id $dist_type $client_name
git reset --hard HEAD


client_name="MASTECH"
sh ./ipa-build.sh ./ ~/ $commit_id $dist_type $client_name
git reset --hard HEAD
