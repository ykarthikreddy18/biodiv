package species

class NamelistController {

    def index() { }
	
	
	/**
	 * input : taxon id of ibp 
	 * @return A map which contain keys as dirty, clean and working list. Values of this key is again a map with key as name and id
	 * 
	 */
	def getNamesFromTaxon(){
		//[dirtyList:[name:'aa', id:11], workingList:[name:'aa', id:11]]	
	}
	
	/**
	 * input : taxon id of ibp
	 * @return All detail like kingdom, order etc
	 */
	def getNameDetails(){
		//[name:'aa', kingdom:'kk', .....]
	
	}
	
	/**
	 * input : string name
	 * @return list of map where each map represent one result
	 */
	def searchCol(){
		//[[name:'aa', namestatus:'st', colId:34, rank:4, group:'plant', sourceDatabase:'sb'], [name:'bb', namestatus:'st', colId:34, rank:4, group:'plant', sourceDatabase:'sb']]
	}
	/**
	 * input : col id
	 * @return same as api getNameDetails
	 */
	def getColDetails(){
		//same getNameDetails
	}
}