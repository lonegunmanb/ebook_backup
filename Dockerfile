FROM filebrowser/filebrowser

ADD book /srv

ENTRYPOINT [ "/filebrowser" ]