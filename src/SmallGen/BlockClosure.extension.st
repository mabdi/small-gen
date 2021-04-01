Extension { #name : #BlockClosure }

{ #category : #'*SmallGen' }
BlockClosure >> smallgen_state [
	^ (SGBlockClosure with: self) dictionaryRepresentation
]
