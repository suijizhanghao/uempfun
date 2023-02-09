location ^~ {{location}} {
    alias "{{document_root}}";

    {{acl_configuration}}

    include "/cib/nginx/conf/cib/protect-hidden-files.conf";
    include "/cib/nginx/conf/cib/php-fpm.conf";
}

{{additional_configuration}}
