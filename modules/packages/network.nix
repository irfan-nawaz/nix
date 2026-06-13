{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Networking / diagnostics
    inetutils
    netcat
    mtr
    nmap
    zenmap
    tcpdump
    wireshark
    termshark
    iperf3
    whois
    bandwhich
    bmon
    sniffnet
    iftop
    mdns-scanner
    arp-scan
    masscan
    trippy
    dstp
    nload
    cariddi
    rustscan
    gping # graphical ping with latency graph; aliased as `pingg`
    httpie
    xh
    ngrok

    # Tunnels / proxies
    cloudflared
    tailscale

    # API / request tools
    atac
  ];
}
