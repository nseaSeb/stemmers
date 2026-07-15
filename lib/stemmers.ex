defmodule Stemmers do
  @moduledoc """
  Snowball stemming for Elixir, backed by the Rust [`rust-stemmers`](https://github.com/CurrySoftware/rust-stemmers)
  crate through a Rustler NIF.

  Unlike the pure-Elixir `stemmer` package (English only), this supports the full
  Snowball language set — French included — and is a maintained replacement for the
  abandoned `stemex`.

      iex> Stemmers.stem("mangeant", :french)
      "mang"

      iex> Stemmers.stem("running", :english)
      "run"

  ## Safety

  `rust-stemmers` is safe Rust (no `unsafe`), and Rustler converts any Rust panic
  into an Elixir exception, so a bad input cannot bring down the BEAM. `stem_all/2`
  is scheduled on a dirty CPU scheduler so large batches never stall a normal
  scheduler thread.
  """

  alias Stemmers.Native

  @languages ~w(arabic danish dutch english finnish french german greek
                 hungarian italian norwegian portuguese romanian russian
                 spanish swedish tamil turkish)a

  @type language ::
          :arabic
          | :danish
          | :dutch
          | :english
          | :finnish
          | :french
          | :german
          | :greek
          | :hungarian
          | :italian
          | :norwegian
          | :portuguese
          | :romanian
          | :russian
          | :spanish
          | :swedish
          | :tamil
          | :turkish

  @doc "The list of supported Snowball languages, as atoms."
  @spec supported_languages() :: [language()]
  def supported_languages, do: @languages

  @doc "Whether `lang` is a supported Snowball language."
  @spec supported?(atom()) :: boolean()
  def supported?(lang), do: lang in @languages

  @doc """
  Stem a single word in the given language.

  Raises `ArgumentError` on an unsupported language so callers get a clear message
  instead of an opaque NIF decode error.
  """
  @spec stem(String.t(), language()) :: String.t()
  def stem(word, lang) when is_binary(word) do
    validate_language!(lang)
    Native.stem(word, lang)
  end

  @doc "Stem a list of words in the given language, reusing one stemmer instance."
  @spec stem_all([String.t()], language()) :: [String.t()]
  def stem_all(words, lang) when is_list(words) do
    validate_language!(lang)
    Native.stem_all(words, lang)
  end

  defp validate_language!(lang) when lang in @languages, do: :ok

  defp validate_language!(lang) do
    raise ArgumentError,
          "unsupported language #{inspect(lang)}. Supported: #{inspect(@languages)}"
  end
end
