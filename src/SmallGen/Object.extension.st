Extension { #name : #Object }

{ #category : #'*SmallGen' }
Object >> smallGenCallRecords [
	^ SGCallHistory for: self
]
