class ClaudeLifeline < Formula
  desc "Real-time statusline for Claude Code — context, cost, git, cache hit rate, and session duration"
  homepage "https://github.com/lokesh2021/claude-lifeline"
  url "https://github.com/lokesh2021/claude-lifeline/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "53a6f7f039e9603b4dbee53184fb06aca6a880eef1df23bf686c53c7b2c5eb6d"
  license "MIT"

  depends_on "jq"
  depends_on "gh"

  def install
    bin.install "statusline.sh" => "claude-lifeline"
  end

  def caveats
    <<~EOS
      To enable claude-lifeline in Claude Code, add the following to
      ~/.claude/settings.json:

        {
          "statusLine": {
            "type": "command",
            "command": "claude-lifeline"
          }
        }

      Then restart Claude Code.

      Optional — add to your ~/.zshrc for extra features:
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
