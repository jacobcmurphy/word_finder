class WordType < ActiveRecord::Base
  belongs_to :word

  PARTS_OF_SPEECH = {
    noun: 'Noun',
    # plural: 'Plural',
    noun_phrase: 'Noun phrase',
    verb_participle: 'Verb (participle)',
    verb_transitive: 'Verb (transitive)',
    verb_intransitive: 'Verb (intransitive)',
    adjective: 'Adjective',
    adverb: 'Adverb',
    conjunction: 'Conjunction',
    preposition: 'Preposition',
    interjection: 'Interjection',
    pronoun: 'Pronound',
    article_definite: 'Article (definite)',
    article_indefinite: 'Article (indefinite)',
    # nominative: 'Nominative'
  }
end
