{{external_configuration}}

server {
    # Port to listen on, can also be set in IP:PORT format
    {{https_listen_configuration}}

    root {{document_root}};

    {{server_name_configuration}}

    ssl_certificate      conf.d/certs/server.crt;
    ssl_certificate_key  conf.d/certs/server.key;

    {{acl_configuration}}

    {{additional_configuration}}

    include  "/cib/nginx/conf/conf.d/cib/*.conf";
}
