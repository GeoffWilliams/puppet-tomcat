
# Create a tomcat instance
tomcat::instance { "myapp_dev":
    instance_user => "tomcat",
    https_port    => 8080,
    http_port     => 8081,
    jmx_port      => 8088,
    shutdown_port => 8089,
    jmx_enabled   => true,
}

# Create another tomcat instance
tomcat::instance { "myotherapp_prod":
    instance_user => "tomcat",
    https_port    => 8090,
    http_port     => 8091,
    jmx_port      => 8098,
    shutdown_port => 8099,
    jmx_enabled   => true,
}

# disabled tomcat instance
tomcat::instance { "mydisabledapp_dev":
    ensure        => false,
    enable        => false,
    instance_user => "tomcat",
    https_port    => 8100,
    http_port     => 8101,
    jmx_port      => 8108,
    shutdown_port => 8109,
    jmx_enabled   => false,
}

