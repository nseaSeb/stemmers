defmodule StemmersTest do
  use ExUnit.Case, async: true
  doctest Stemmers

  describe "stem/2" do
    test "stems French" do
      assert Stemmers.stem("mangeant", :french) == "mang"
      assert Stemmers.stem("chevaux", :french) == "cheval"
    end

    test "stems English" do
      assert Stemmers.stem("running", :english) == "run"
      assert Stemmers.stem("fruitlessly", :english) == "fruitless"
    end

    test "collapses inflections of the same lemma to one stem" do
      # French: several forms of "manger" reduce to the same stem
      assert Stemmers.stem("mangeant", :french) == Stemmers.stem("manges", :french)
      # English: forms of "connect" collapse
      assert Stemmers.stem("connections", :english) == Stemmers.stem("connected", :english)
    end

    test "raises on unsupported language" do
      assert_raise ArgumentError, ~r/unsupported language :klingon/, fn ->
        Stemmers.stem("word", :klingon)
      end
    end
  end

  describe "stem_all/2" do
    test "stems a batch reusing one stemmer" do
      assert Stemmers.stem_all(["running", "jumped", "connections"], :english) ==
               ["run", "jump", "connect"]
    end

    test "handles an empty list" do
      assert Stemmers.stem_all([], :french) == []
    end
  end

  describe "supported languages" do
    test "supported_languages/0 lists the Snowball set" do
      langs = Stemmers.supported_languages()
      assert :french in langs
      assert :english in langs
      assert length(langs) == 18
    end

    test "supported?/1" do
      assert Stemmers.supported?(:french)
      refute Stemmers.supported?(:klingon)
    end
  end
end
