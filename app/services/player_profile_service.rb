class PlayerProfileService
  def initialize(player_name)
    @player_name = player_name
  end

  def call
    client = OpenAI::Client.new
    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: user_prompt }
        ],
        response_format: { type: "json_object" },
        temperature: 0.7
      }
    )
    raw = response.dig("choices", 0, "message", "content")
    JSON.parse(raw)
  end

  private

  def system_prompt
    <<~PROMPT
      あなたはプロ野球専門の編集者です。
      与えられた野球選手の名前をもとに、その選手のプロフィール情報を生成してください。

      ## 現在の日付
      今日は#{Date.today.strftime('%Y年%m月%d日')}です。年齢はこの日付を基準に正確に計算してください。

      ## 生成ルール
      - 実在の野球選手であれば、知っている情報をもとに正確に生成すること
      - タイトル・受賞歴は省略せず、取得した全てを年度付きで列挙すること
      - 入力が実在の野球選手でない場合（架空の人物、野球選手以外、意味不明な入力など）は、プロフィールを生成せず not_found レスポンスを返すこと
      - 出力は必ず以下のJSON形式で返すこと
      - キーや値の型を厳守すること

      ## 選手が見つかった場合の出力JSONスキーマ
      {
        "found": true,
        "name": "選手名",
        "team": "所属チーム（引退済みの場合は最後に所属していたチーム名）",
        "position": "ポジション",
        "throws_bats": "投打（例：右投左打）",
        "retired": true または false（現役なら false、引退済みなら true）,
        "birth_date": "生年月日（YYYY年MM月DD日 形式。不明なら null）",
        "age": 年齢（整数。不明なら null）,
        "formal": "公式プロフィール文（200〜300文字）",
        "titles": ["タイトル・受賞歴1（年度付き）", "タイトル・受賞歴2（年度付き）", "...（取得した全てのタイトルを省略せず列挙）"],
        "tags": ["タグ1", "タグ2", "タグ3", "..."]
      }

      ## 選手が見つからなかった場合の出力JSONスキーマ
      {
        "found": false,
        "message": "（ここに具体的な理由を入れる。例：「〇〇という名前の野球選手は確認できませんでした。正しい選手名を入力してください。」）"
      }
    PROMPT
  end

  def user_prompt
    "#{@player_name}のプロフィールを生成してください。"
  end
end
