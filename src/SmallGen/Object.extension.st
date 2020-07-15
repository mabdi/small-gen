Extension { #name : #Object }

{ #category : #'*SmallGen' }
Object >> smallgen_enterMethod: aSelector args: args [
	" do nothing "
]

{ #category : #'*SmallGen' }
Object >> smallgen_exitMethod: aSelector args: args result: aResult preCallData: preCallData [
	" do nothing "

	
]

{ #category : #'*SmallGen' }
Object >> smallgen_state [
	^ (SGSkipped with: self) dictionaryRepresentation
]
