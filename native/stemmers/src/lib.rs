use rust_stemmers::{Algorithm, Stemmer};

// Maps 1:1 to Elixir atoms (`:french`, `:english`, ...) via NifUnitEnum.
// These are exactly the Snowball algorithms shipped by rust-stemmers.
#[derive(rustler::NifUnitEnum)]
enum Language {
    Arabic,
    Danish,
    Dutch,
    English,
    Finnish,
    French,
    German,
    Greek,
    Hungarian,
    Italian,
    Norwegian,
    Portuguese,
    Romanian,
    Russian,
    Spanish,
    Swedish,
    Tamil,
    Turkish,
}

impl Language {
    fn algorithm(&self) -> Algorithm {
        match self {
            Language::Arabic => Algorithm::Arabic,
            Language::Danish => Algorithm::Danish,
            Language::Dutch => Algorithm::Dutch,
            Language::English => Algorithm::English,
            Language::Finnish => Algorithm::Finnish,
            Language::French => Algorithm::French,
            Language::German => Algorithm::German,
            Language::Greek => Algorithm::Greek,
            Language::Hungarian => Algorithm::Hungarian,
            Language::Italian => Algorithm::Italian,
            Language::Norwegian => Algorithm::Norwegian,
            Language::Portuguese => Algorithm::Portuguese,
            Language::Romanian => Algorithm::Romanian,
            Language::Russian => Algorithm::Russian,
            Language::Spanish => Algorithm::Spanish,
            Language::Swedish => Algorithm::Swedish,
            Language::Tamil => Algorithm::Tamil,
            Language::Turkish => Algorithm::Turkish,
        }
    }
}

/// Stem a single word. Runs in microseconds → a regular (non-dirty) NIF is fine.
#[rustler::nif]
fn stem(word: String, lang: Language) -> String {
    let stemmer = Stemmer::create(lang.algorithm());
    stemmer.stem(&word).into_owned()
}

/// Stem a batch of words with a single stemmer instance.
/// Scheduled on a dirty CPU scheduler: a large batch could otherwise exceed the
/// ~1ms budget of a normal NIF and stall the BEAM scheduler thread.
#[rustler::nif(schedule = "DirtyCpu")]
fn stem_all(words: Vec<String>, lang: Language) -> Vec<String> {
    let stemmer = Stemmer::create(lang.algorithm());
    words
        .iter()
        .map(|w| stemmer.stem(w).into_owned())
        .collect()
}

rustler::init!("Elixir.Stemmers.Native");
