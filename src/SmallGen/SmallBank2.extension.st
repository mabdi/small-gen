Extension { #name : #SmallBank2 }

{ #category : #'*SmallGen' }
SmallBank2 class >> example [
	| b |
	b:= SmallBank2 new.
	b deposit: 100 atRandom.
	b balance > 10 ifTrue: [ b withdraw: 10 ]
]
