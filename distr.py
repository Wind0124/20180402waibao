# coding=utf-8

"""
    * User:  answer.huang
    * Email: aihoo91@gmail.com
    * Date:  15/3/31
    * Time:  18:33
    * Blog:  answerhuang.duapp.com
    """

import time
import urllib2
import time
import json
import mimetypes
import os,sys
import smtplib
from email.MIMEText import MIMEText
from email.MIMEMultipart import MIMEMultipart

import json

#蒲公英应用上传地址
url = 'http://www.pgyer.com/apiv1/app/upload'
#蒲公英提供的 用户Key
uKey = 'eb8fd206d1ff281f00eb21da93c26940'
#上传文件的文件名（这个可随便取，但一定要以 ipa 结尾）
file_name = '/Users/vincent/archives/Cubicle-20151006190538.xcarchive/Cubicle-1.0.ipa'
#蒲公英提供的 API Key
_api_key = '5638407cde7a458240cd6b98a240999e'
#安装应用时需要输入的密码，这个可不填
installPassword = '111111'

# 运行时环境变量字典
environsDict = os.environ
#此次 jenkins 构建版本号
#jenkins_build_number = environsDict['BUILD_NUMBER']

#项目名称，用在 拼接 tomcat 文件地址
project_name = 'ios_user_client'


ipa_file_path = sys.argv[1]
print ipa_file_path

#请求字典编码
def _encode_multipart(params_dict):
    boundary = '----------%s' % hex(int(time.time() * 1000))
    data = []
    for k, v in params_dict.items():
        data.append('--%s' % boundary)
        if hasattr(v, 'read'):
            filename = getattr(v, 'name', '')
            content = v.read()
            decoded_content = content.decode('ISO-8859-1')
            data.append('Content-Disposition: form-data; name="%s"; filename="kangda.ipa"' % k)
            data.append('Content-Type: application/octet-stream\r\n')
            data.append(decoded_content)
        else:
            data.append('Content-Disposition: form-data; name="%s"\r\n' % k)
            data.append(v if isinstance(v, str) else v.decode('utf-8'))
    data.append('--%s--\r\n' % boundary)
    return '\r\n'.join(data), boundary


#处理 蒲公英 上传结果
def handle_resule(result):
    json_result = json.loads(result)
    if json_result['code'] is 0:
        print "upload to pugongyin success..."
        #send_Email(json_result)

#发送邮件
def send_Email(json_result):
    appName = json_result['data']['appName']
    appKey = json_result['data']['appKey']
    appVersion = json_result['data']['appVersion']
    appBuildVersion = json_result['data']['appBuildVersion']
    appShortcutUrl = json_result['data']['appShortcutUrl']
    #邮件接受者
    mail_receiver = ['aihoo91@gmail.com']
    #根据不同邮箱配置 host，user，和pwd
    mail_host = '**********'
    mail_user = '**********'
    mail_pwd = '**********'
    mail_to = ','.join(mail_receiver)
    
    msg = MIMEMultipart()
    
    environsString = '<h3>本次打包相关信息</h3><p>'
    #environsString += '<p>ipa 包下载地址 : ' + ipa_file_tomcat_http_url + '<p>'
    environsString += '<p>你也可从蒲公英网站在线安装 : ' + 'http://www.pgyer.com/' + str(appShortcutUrl) + '   密码 : ' + installPassword + '<p>'
    environsString += '<li><a href="itms-services://?action=download-manifest&url=https://ssl.pgyer.com/app/plist/' + str(appKey) + '">点我直接安装</a></li>'
    message = environsString
    body = MIMEText(message, _subtype='html', _charset='utf-8')
    msg.attach(body)
    msg['To'] = mail_to
    msg['from'] = mail_user
    msg['subject'] = '最新打包文件'
    
    try:
        s = smtplib.SMTP()
        s.connect(mail_host)
        s.login(mail_user, mail_pwd)
        
        s.sendmail(mail_user, mail_receiver, msg.as_string())
        s.close()
        
        print 'success'
    except Exception, e:
        print e

#############################################################
#请求参数字典
params = {
    'uKey': uKey,
    '_api_key': _api_key,
    'file': open(ipa_file_path, 'rb'),
    'publishRange': '2',
    #’password': installPassword

}

coded_params, boundary = _encode_multipart(params)
req = urllib2.Request(url, coded_params.encode('ISO-8859-1'))
req.add_header('Content-Type', 'multipart/form-data; boundary=%s' % boundary)
try:
    resp = urllib2.urlopen(req)
    body = resp.read().decode('utf-8')
    handle_resule(body)

except urllib2.HTTPError as e:
    print(e.fp.read())






