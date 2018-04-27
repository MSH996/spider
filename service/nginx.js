/**
 *
 * 作者：weich
 * 邮箱：1329555958@qq.com
 * 日期：2018/4/27
 *
 * 未经作者本人同意，不允许将此文件用作其他用途。违者必究。
 *
 * @ngdoc
 * @author          weich
 * @name            Role
 * @description
 */
module.exports = {
    USE_NGINX:USE_NGINX,
    assignUrl: assignUrl,
    reload: reload
};

var Hosts = require('./hosts');
var urls = require('./utils').urls;
var Path = require('path');
var Fs = require('fs');
var _ = require('lodash'); //https://lodash.com/docs/4.17.5
var Exec = require('child_process').exec;

var CONFIG_FILE_PATH = Path.resolve('/etc/nginx/config.d/spider.conf');
var USE_NGINX = true;

var genConfig = _.template(Fs.readFileSync(Path.resolve(__dirname, 'nginx_lodash_template.txt')));

function makeConfigFile(hosts) {
    var config = genConfig({hosts: hosts});
    console.log(config);
    Fs.writeFileSync(CONFIG_FILE_PATH, config);
}

function reload(hosts) {
    makeConfigFile();
    Exec('nginx -s reload', function (err, stdout, stderr) {
        console.log(err, stdout, stderr);
    });
}

function assignUrl(host) {
    // only exec on master
    if (!USE_NGINX || !Hosts.isMaster()) {
        return;
    }
    var baseUrl = Hosts.getMaster();
    if (host.master) {
        return;
    }

    host.url = urls.resoleUri(baseUrl, host.name);
}


if (module === require.main) {
    makeConfigFile();
}