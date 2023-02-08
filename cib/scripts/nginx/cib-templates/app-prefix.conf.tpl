location ^~ {{location}} {
    alias "{{document_root}}";

    {{acl_configuration}}

    include "/cib/nginx/conf/cib/protect-hidden-files.conf";
}

{{additional_configuration}}
