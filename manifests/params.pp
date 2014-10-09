class tomcat::params {
    $bin_dir = "bin"
    $common_dir = "common"
    $conf_dir = "conf"
    $catalina_dir = "Catalina"
    $keystore_dir = "keystore"
    $lib_dir = "lib"
    $log_dir = "logs"
    $server_dir = "server"
    $shared_dir = "shared"
    $temp_dir = "temp"
    $webapps_dir = "webapps"
    $work_dir = "work"
    $tomcat_user = "tomcat"
    $tomcat_group = "tomcat"

    # default permissions - directories have +1 to each bit...
    $tomcat_mode = "0644"
}
