module AdminHelper
  def process_natural_language_query(question)
    # 1️⃣ Configure Ollama once
    RubyLLM.configure do |config|
      config.ollama_api_base = "http://localhost:11434/v1"
    end

    # Two chats: one for NL→SQL (duckdb-nsql), one for summarization (llama3.2)
    sql_chat   = RubyLLM.chat(model: "duckdb-nsql", provider: :ollama)
    llama_chat = RubyLLM.chat(model: "llama3.2",    provider: :ollama)

    begin
      # 2️⃣ Generate SQL with duckdb-nsql
      sql_prompt = <<~PROMPT
        Database schema:
        - users(id, name, email, status, created_at)
        - orders(id, user_id, total, status, order_date)
        - products(id, name, price, category, stock)

        Convert the following question into a valid SQL query.
        Only respond with the SQL.

        Question: "#{question}"
      PROMPT

      sql_response = sql_chat.ask(sql_prompt)
      sql_query = sql_response.content.strip

      # 3️⃣ Execute the generated SQL with ActiveRecord
      rows = ActiveRecord::Base.connection.exec_query(sql_query).to_a

      # 4️⃣ Summarize results with llama3.2
      summary_prompt = <<~PROMPT
        The user asked: "#{question}"

        Here are the SQL results (JSON):
        #{rows.to_json}

        Provide a short, clear natural-language summary of these results.
      PROMPT

      summary_response = llama_chat.ask(summary_prompt)
      summary = summary_response.content.strip

      {
        success: true,
        data: rows,
        summary: summary,
        query_type: "duckdb_nsql",
        sql_generated: sql_query
      }
    rescue => e
      Rails.logger.error "Query failed: #{e.message}"
      {
        success: false,
        error: "Error: #{e.message}",
        suggestion: "Try rephrasing your question or ask about users, orders, or products."
      }
    end
  end
end
