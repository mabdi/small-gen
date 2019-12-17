Extension { #name : #SmallBank }

{ #category : #'*SmallGen' }
SmallBank class >> example [
	| b |
	b:= SmallBank new.
	b deposit: 100 atRandom.
	b balance > 10 ifTrue: [ b withdraw: 10 ]
]
