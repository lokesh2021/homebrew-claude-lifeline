class ClaudeLifeline < Formula
  desc "Real-time statusline for Claude Code — context, cost, git, cache hit rate, and session duration"
  homepage "https://github.com/lokesh2021/claude-lifeline"
  url "https://github.com/lokesh2021/claude-lifeline/archive/refs/tags/v1.1.1.tar.gz"
  sha256 "7bdcd38c2a6a75f8df111d922c7c7d4b470b3e7bd8c86408529b7acfa6fa731f"
  license "MIT"

  depends_on "jq"
  depends_on "gh"

  def install
    bin.install "statusline.sh" => "claude-lifeline"
    bin.install "report.sh" => "claude-lifeline-report"
  end

  def post_install
    settings_file = Pathname.new(Dir.home) / ".claude" / "settings.json"
    claude_dir = Pathname.new(Dir.home) / ".claude"
    claude_dir.mkpath

    if settings_file.exist?
      require "json"
      begin
        settings = JSON.parse(settings_file.read)
        if settings.key?("statusLine")
          opoo "statusLine already configured in ~/.claude/settings.json — skipping"
        else
          settings["statusLine"] = { "type" => "command", "command" => "claude-lifeline" }
          settings_file.write(JSON.pretty_generate(settings))
          ohai "Added statusLine config to ~/.claude/settings.json"
        end
      rescue JSON::ParserError
        opoo "Could not parse ~/.claude/settings.json — add statusLine config manually"
      end
    else
      settings_file.write(JSON.pretty_generate({
        "statusLine" => { "type" => "command", "command" => "claude-lifeline" }
      }))
      ohai "Created ~/.claude/settings.json with statusLine config"
    end
  end

  def caveats
    <<~EOS
      Restart Claude Code to activate the statusline.

      Weekly usage report:
        claude-lifeline-report

      Optional env vars (add to ~/.zshrc):
        export OBSIDIAN_VAULT="$HOME/Documents/MyVault"
        export ANTHROPIC_ADMIN_API_KEY="sk-ant-admin01-..."
    EOS
  end

  test do
    payload = <<~JSON
      {
        "model": {"display_name": "Claude Sonnet 4.6"},
        "context_window": {
          "used_percentage": 10,
          "context_window_size": 200000,
          "current_usage": {
            "input_tokens": 5000,
            "cache_creation_input_tokens": 0,
            "cache_read_input_tokens": 15000,
            "output_tokens": 500
          }
        },
        "cost": {"total_cost_usd": 0.005, "total_duration_ms": 60000},
        "workspace": {"current_dir": "."}
      }
    JSON
    output = pipe_output("#{bin}/claude-lifeline", payload, 0)
    assert_match "10%", output
    assert_match "Claude Sonnet 4.6", output
  end
end
