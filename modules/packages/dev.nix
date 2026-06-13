{ pkgs, pkgs-unstable, ... }:
{
  environment.systemPackages =
    with pkgs;
    [
      # Databases
      usql
      sqlite

      # Dev-heavy media
      ffmpeg
      smassh
      sampler

      # Terminal recording / sharing
      asciinema
      t-rec

      # Forge CLIs (GitHub + GitLab) -- repo / PR / SSH-key management.
      gh
      glab

      # Bookmarks
      bmm

      # Documentation / writing / slides
      slides
      runme
      presenterm
      tui-journal
    ]
    ++ (with pkgs-unstable; [
      # AI tools — release frequently, keep on unstable
      yai
      pi-coding-agent

      # tmux session manager — active development
      sesh
    ])
    ++ [
      # Git workflow
      git-absorb # `git absorb` auto-rewrites staged hunks into the right fixup commit

      # Local CI
      act # run GitHub Actions locally: `act push` fires your CI workflow without pushing

      # Local AI inference
      ollama # serves Llama/Mistral/Gemma locally; `ollama run llama3` on first use
    ];
}
