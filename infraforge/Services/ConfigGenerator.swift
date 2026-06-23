import Foundation

struct ConfigGenerator {

    static func generate(_ config: HTTPServerConfig) -> String {
        switch config.serverType {
        case .apache: apache(config)
        case .nginx: nginx(config)
        }
    }

    // MARK: - Apache

    static func apache(_ c: HTTPServerConfig) -> String {
        var out = ""
        let primary = c.primaryDomain
        let aliases = c.domainList.dropFirst().joined(separator: " ")

        if c.http {
            out += "<VirtualHost *:80>\n"
            out += "    ServerName \(primary)\n"
            if !aliases.isEmpty { out += "    ServerAlias \(aliases)\n" }
            out += "\n"

            if c.https && c.redirect {
                out += "    Redirect permanent / https://\(primary)/\n"
            } else if c.isProxy {
                out += apacheProxy(c.proxyTarget, indent: 4)
            } else {
                out += apacheDocRoot(c.path, indent: 4)
            }

            out += "</VirtualHost>\n"
        }

        if c.https {
            if c.http { out += "\n" }
            out += "<VirtualHost *:443>\n"
            out += "    ServerName \(primary)\n"
            if !aliases.isEmpty { out += "    ServerAlias \(aliases)\n" }
            out += "\n"

            if c.isProxy {
                out += apacheProxy(c.proxyTarget, indent: 4)
            } else {
                out += apacheDocRoot(c.path, indent: 4)
            }

            out += "\n"
            out += "    SSLEngine on\n"
            out += apacheSSL(c, indent: 4)
            out += "</VirtualHost>\n"
        }

        return out
    }

    private static func apacheDocRoot(_ path: String, indent: Int) -> String {
        let sp = String(repeating: " ", count: indent)
        return """
        \(sp)DocumentRoot \(path)
        \(sp)
        \(sp)<Directory \(path)>
        \(sp)    AllowOverride All
        \(sp)    Require all granted
        \(sp)</Directory>\n
        """
    }

    private static func apacheProxy(_ target: String, indent: Int) -> String {
        let sp = String(repeating: " ", count: indent)
        return """
        \(sp)ProxyPreserveHost On
        \(sp)ProxyPass / http://\(target)/
        \(sp)ProxyPassReverse / http://\(target)/\n
        """
    }

    private static func apacheSSL(_ c: HTTPServerConfig, indent: Int) -> String {
        let sp = String(repeating: " ", count: indent)
        let primary = c.primaryDomain
        switch c.ssl {
        case .certbot:
            return """
            \(sp)SSLCertificateFile /etc/letsencrypt/live/\(primary)/fullchain.pem
            \(sp)SSLCertificateKeyFile /etc/letsencrypt/live/\(primary)/privkey.pem
            \(sp)Include /etc/letsencrypt/options-ssl-apache.conf\n
            """
        case .snakeoil:
            return """
            \(sp)SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
            \(sp)SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key\n
            """
        case .custom:
            return """
            \(sp)SSLCertificateFile \(c.sslCustomCert)
            \(sp)SSLCertificateKeyFile \(c.sslCustomKey)\n
            """
        }
    }

    // MARK: - Nginx


    static func nginx(_ c: HTTPServerConfig) -> String {
        var out = ""
        let primary = c.primaryDomain
        let serverNames = c.domainList.joined(separator: " ")

        if c.http {
            out += "server {\n"
            out += "    listen 80;\n"
            out += "    listen [::]:80;\n"
            out += "    server_name \(serverNames);\n"
            out += "\n"

            if c.https && c.redirect {
                out += "    return 301 https://\(primary)$request_uri;\n"
            } else if c.isProxy {
                out += nginxProxyLocation(c.proxyTarget, indent: 4)
            } else {
                out += nginxStaticContent(c.path, indent: 4)
            }

            out += "}\n"
        }

        if c.https {
            if c.http { out += "\n" }
            out += "server {\n"
            out += "    listen 443 ssl;\n"
            out += "    listen [::]:443 ssl;\n"
            out += "    server_name \(serverNames);\n"
            out += "\n"
            out += nginxSSL(c, indent: 4)
            out += "\n"

            if c.isProxy {
                out += nginxProxyLocation(c.proxyTarget, indent: 4)
            } else {
                out += nginxStaticContent(c.path, indent: 4)
            }

            out += "}\n"
        }

        return out
    }

    private static func nginxStaticContent(_ path: String, indent: Int) -> String {
        let sp = String(repeating: " ", count: indent)
        return """
        \(sp)root \(path);
        \(sp)index index.html index.htm index.php;
        \(sp)
        \(sp)location / {
        \(sp)    try_files $uri $uri/ =404;
        \(sp)}\n
        """
    }

    private static func nginxProxyLocation(_ target: String, indent: Int) -> String {
        let sp = String(repeating: " ", count: indent)
        return """
        \(sp)location / {
        \(sp)    proxy_pass http://\(target);
        \(sp)    proxy_set_header Host $host;
        \(sp)    proxy_set_header X-Real-IP $remote_addr;
        \(sp)    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        \(sp)    proxy_set_header X-Forwarded-Proto $scheme;
        \(sp)}\n
        """
    }

    private static func nginxSSL(_ c: HTTPServerConfig, indent: Int) -> String {
        let sp = String(repeating: " ", count: indent)
        let primary = c.primaryDomain
        switch c.ssl {
        case .certbot:
            return """
            \(sp)ssl_certificate /etc/letsencrypt/live/\(primary)/fullchain.pem;
            \(sp)ssl_certificate_key /etc/letsencrypt/live/\(primary)/privkey.pem;
            \(sp)include /etc/letsencrypt/options-ssl-nginx.conf;
            \(sp)ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;\n
            """
        case .snakeoil:
            return """
            \(sp)ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
            \(sp)ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;\n
            """
        case .custom:
            return """
            \(sp)ssl_certificate \(c.sslCustomCert);
            \(sp)ssl_certificate_key \(c.sslCustomKey);\n
            """
        }
    }
}