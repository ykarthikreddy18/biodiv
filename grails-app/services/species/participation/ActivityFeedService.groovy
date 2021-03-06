package species.participation

import java.text.SimpleDateFormat
import org.hibernate.Hibernate;

import species.auth.SUser;
import species.groups.UserGroup;
import species.Species;
import species.SpeciesField

class ActivityFeedService {
	
	static final String COMMENT_ADDED = "Added a comment"
	static final String COMMENT_IN_REPLY_TO = "In reply to"
	
	
	//checklist related
	static final String CHECKLIST_CREATED = "Checklist created"
	static final String CHECKLIST_UPDATED = "Checklist updated"
	//static final String CHECKLIST_POSTED_ON_GROUP = "Posted checklist to group"
	//static final String CHECKLIST_REMOVED_FROM_GROUP = "Removed checklist from group"
	
	
	//observation related
	static final String OBSERVATION_CREATED = "Observation created"
	static final String OBSERVATION_UPDATED = "Observation updated"
	static final String OBSERVATION_FLAGGED = "Flagged"
	static final String REMOVED_FLAG = "Flag removed"
	static final String OBSERVATION_FLAG_DELETED = "Flag deleted"
	static final String OBSERVATION_DELETED = "Deleted observation"
	
	static final String SPECIES_RECOMMENDED = "Suggested species name"
	static final String SPECIES_AGREED_ON = "Agreed on species name"
	static final String RECOMMENDATION_REMOVED = "Suggestion removed"
	//static final String OBSERVATION_POSTED_ON_GROUP = "Posted observation to group"
	//static final String OBSERVATION_REMOVED_FROM_GROUP = "Removed observation from group"
	
    //Feature Related
    static final String FEATURED = "Featured";
    static final String UNFEATURED = "UnFeatured";

	//group related
	static final String USERGROUP_CREATED = "Group created"
	static final String USERGROUP_UPDATED = "Group updated"
	static final String MEMBER_JOINED = "Joined group"
	static final String MEMBER_LEFT = "Left Group"
	static final String MEMBER_ROLE_UPDATED = "Role updated"
	static final String USER_REGISTERED = "Registered to portal"
	static final String RESOURCE_POSTED_ON_GROUP = "Posted resource"
	static final String RESOURCE_REMOVED_FROM_GROUP = "Removed resoruce"
	//static final String RESOURCE_BULK_POST = "Bulk posting"
	//static final String RESOURCE_BULK_REMOVE = "Bulk removal"
	
	
	//document related
	static final String DOCUMENT_CREATED = "Document created"
	static final String DOCUMENT_UPDATED = "Document updated"
	//static final String DOCUMENT_POSTED_ON_GROUP = "Posted document to group"
	//static final String DOCUMENT_REMOVED_FROM_GROUP = "Removed document from group"
	
	//species related
	//static final String SPECIES_POSTED_ON_GROUP = "Posted species to group"
	//static final String SPECIES_REMOVED_FROM_GROUP = "Removed species from group"
	static final String SPECIES_CREATED = "Created species"
	static final String SPECIES_UPDATED = "Updated species gallery"  //updation mail on when media changes
	static final String SPECIES_FIELD_UPDATED = "Updated species field"
	static final String SPECIES_FIELD_CREATED = "Added species field"
	static final String SPECIES_FIELD_DELETED = "Deleted species field"
	static final String SPECIES_SYNONYM_CREATED = "Added synonym"
	static final String SPECIES_SYNONYM_UPDATED = "Updated synonym"
	static final String SPECIES_SYNONYM_DELETED = "Deleted synonym"
	static final String SPECIES_COMMONNAME_CREATED = "Added common name"
	static final String SPECIES_COMMONNAME_UPDATED = "Updated common name"
	static final String SPECIES_COMMONNAME_DELETED = "Deleted common name"
	static final String SPECIES_HIERARCHY_CREATED = "Added hierarchy"
	static final String SPECIES_HIERARCHY_UPDATED = "Updated hierarchy"
	static final String SPECIES_HIERARCHY_DELETED = "Deleted hierarchy"
	
	static final String OLDER = "older"
	static final String NEWER = "newer"
	
	static final String READ_ONLY = "readOnly"
	static final String EDITABLE = "editable"
	
	static final String AUTO = "auto"
	static final String MANUAL= "manual"
	
	static final String LATEST_FIRST = "latestFirst"
	static final String OLDEST_FIRST = "oldestFirst"
	
	static final String GENERIC = "Generic"
	static final String SPECIFIC = "Specific"
	static final String SELECTED = "Selected"
	static final String GROUP_SPECIFIC = "GroupSpecific"
	static final String MY_FEEDS = "MyFeeds"
	static final String USER = "User"
	
	
	static final String ALL = "All"
	static final String OTHER = "other"
	
	//classes for non-db object this should not use as root holder object in any manner 
	//these should be used only for comment with proper root holder object(some domain class)
	static final String SPECIES_SYNONYMS = "species_Synonyms"
	static final String SPECIES_COMMON_NAMES = "species_Common Names"
	static final String SPECIES_MAPS = "species_Occurrence Records"
	static final String SPECIES_TAXON_RECORD_NAME = "species_Taxon Record Name"
	
	
	private static DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd'T'HH:mmZ");
	
	
	static transactional = false
	
	def grailsApplication
	def springSecurityService
	def observationService
	def userGroupService
	
	def getActivityFeeds(params){
//		log.debug params;
		def feeds = ActivityFeed.fetchFeeds(params)
		if(params.feedOrder == OLDEST_FIRST){
			feeds = feeds.reverse()
		}
		return aggregateFeeds(feeds, params)
	}
	
	def getCount(params){
		return ActivityFeed.fetchCount(params)
	}
	
	def addActivityFeed(rootHolder, activityHolder, author, activityType, description=null, isShowable=null, flushImmidiatly=true){
		//to support discussion on comment thread
		def subRootHolderType = rootHolder?.class?.getCanonicalName()
		def subRootHolderId = rootHolder?.id
		if(activityHolder?.class?.getCanonicalName() == Comment.class.getCanonicalName()){
			subRootHolderType = getType(activityHolder)
			subRootHolderId = (activityHolder.isMainThread())? activityHolder.id : activityHolder.fetchMainThread().id
		}
		
		//if not pass through params hiding object whose isShowable = false. In all other cases making feed showable
		isShowable= (isShowable != null) ? isShowable : (rootHolder.hasProperty('isShowable') && rootHolder.isShowable != null)? rootHolder.isShowable : true
		ActivityFeed af = new ActivityFeed(author:author, activityHolderId:activityHolder?.id, \
						activityHolderType:getType(activityHolder), \
						rootHolderId:rootHolder?.id, rootHolderType:getType(rootHolder), \
						isShowable:isShowable,\
						activityType:activityType, subRootHolderType:subRootHolderType, subRootHolderId:subRootHolderId, activityDescrption:description);
		
		ActivityFeed.withNewSession {
				if(!af.save(flush:flushImmidiatly)){
					af.errors.allErrors.each { log.error it }
					return null
				}
		}
		
		//updating time stamp on object after addition of activity
		try {
			updateResourceAssociation(af)
			rootHolder.onAddActivity(af, flushImmidiatly)
		}catch (Exception e) {
			//e.printStackTrace();
		}
		
		Follow.addFollower(rootHolder, author, flushImmidiatly)
		return af
	}
	
	def getDomainObject(className, id){
		def retObj = null
		if(!className || className.trim() == ""){
			return retObj
		}
		
		id = id.toLong()
		switch (className) {
			case [SPECIES_SYNONYMS, SPECIES_COMMON_NAMES, SPECIES_MAPS, SPECIES_TAXON_RECORD_NAME]:
				retObj = [objectType:className, id:id]
				break
			default:
				retObj = grailsApplication.getArtefact("Domain",className)?.getClazz()?.read(id)
				break
		}
		return retObj
	}
	
	// this will return class of object in general used in comment framework
	static getType(obj){
		if(!obj) return null
		
		if(obj instanceof Map){
			return obj.objectType
		}
		
		return Hibernate.getClass(obj).getName();
	}
	
	private aggregateFeeds(List feeds, params){
		if(params.feedType == SPECIFIC || params.checkFeed){
			return feeds
		}
		
		// aggregating object based on feed type
		Set genericFeedSet = new HashSet()
		Set commentFeedSet = new HashSet()
		Set otherFeedSet = new HashSet()
		def retList = []
		feeds.each { it ->
			if(it.rootHolderType == Observation.class.getCanonicalName() || it.rootHolderType == Checklists.class.getCanonicalName() || it.rootHolderType == Species.class.getCanonicalName()){
				//aggregating observation object
				def feedKey = it.rootHolderType + it.rootHolderId;
				if(!genericFeedSet.contains(feedKey)){
					retList.add(it)
					genericFeedSet.add(feedKey)
				}
			}else if(it.rootHolderType == UserGroup.class.getCanonicalName() && it.subRootHolderType == Comment.class.getCanonicalName()){
				//aggregating comment
				def feedKey = it.subRootHolderType + it.subRootHolderId;
				if(!commentFeedSet.contains(feedKey)){
					retList.add(it)
					commentFeedSet.add(feedKey)
				}
			}else if(params.feedType == GROUP_SPECIFIC){
				//adding object as it is if group specific object	
				retList.add(it)
			}else{
				//aggregating other object as well if its not specific to group(ie. myfeeds )
				def feedKey = it.rootHolderType + it.rootHolderId;
				if(!otherFeedSet.contains(feedKey)){
					retList.add(it)
					otherFeedSet.add(feedKey)
				}
			}
		}
		return retList
	}
	
	def deleteFeed(obj){
		ActivityFeed.deleteFeed(obj);
	}
	
	def updateIsShowable(obj){
		ActivityFeed.updateIsShowable(obj);
	}
	
	def updateResourceAssociation(af){
		if(af.activityType != RESOURCE_REMOVED_FROM_GROUP){
			return
		}
		
		//on unpost removing resource from feature table also if user has permission
		def rootHolder = getDomainObject(af.rootHolderType, af.rootHolderId)
		if(rootHolder.instanceOf(UserGroup)){
			return
		}
		
		def activityHolder = getDomainObject(af.activityHolderType, af.activityHolderId)
		def featuredInstance = Featured.findWhere(objectId: af.rootHolderId, objectType: af.rootHolderType, userGroup: activityHolder)
		if(!featuredInstance){
			return
		}
		
		rootHolder.featureCount--
		try{
			featuredInstance.delete(flush:true, failOnError:true)
		}catch (Exception e) {
			log.error "Remove of featuredInstance FAILDED " + featuredInstance
			e.printStackTrace()
		}
	}
	
	def getContextInfo(ActivityFeed feedInstance, params=null){
		
		def activityType = feedInstance.activityType
		def activityDomainObj = getDomainObject(feedInstance.activityHolderType, feedInstance.activityHolderId)
		def activityRootObj = 	getDomainObject(feedInstance.rootHolderType, feedInstance.rootHolderId)
		def text = null
		def activityTitle = null
		
		//log.debug "=== feed === $feedInstance.id === $feedInstance.activityType"
		switch (activityType) {
			case COMMENT_ADDED:
				activityTitle = COMMENT_ADDED  + getCommentContext(activityDomainObj, params)
				text = activityDomainObj.body
				break
			case SPECIES_RECOMMENDED:
				activityTitle = SPECIES_RECOMMENDED + " " + (activityDomainObj ? getSpeciesNameHtml(activityDomainObj, params):feedInstance.activityDescrption)
				break
			case SPECIES_AGREED_ON:
				activityTitle =  SPECIES_AGREED_ON + " " + (activityDomainObj ? getSpeciesNameHtml(activityDomainObj, params):feedInstance.activityDescrption)
				break
			case OBSERVATION_FLAGGED:
				activityTitle = getResType(activityRootObj).capitalize() + " flagged"
				text = feedInstance.activityDescrption
				break
            case REMOVED_FLAG:
				activityTitle = getResType(activityRootObj).capitalize() + " flag removed" 
				text = feedInstance.activityDescrption
				break
			case OBSERVATION_UPDATED:
				activityTitle = OBSERVATION_UPDATED
				text = "User updated the observation details"
				break
			case USERGROUP_CREATED:
				activityTitle = "Group " + getUserGroupHyperLink(activityRootObj) + " created"
				break
			case USERGROUP_UPDATED:
				activityTitle = "Group " + getUserGroupHyperLink(activityRootObj) + " updated"
				break
			case MEMBER_JOINED:
				activityTitle = "Joined group " + getUserGroupHyperLink(activityRootObj)
				break
			case MEMBER_ROLE_UPDATED:
				activityTitle = getUserHyperLink(activityDomainObj, feedInstance.fetchUserGroup()) + "'s role updated"
				break
			case MEMBER_LEFT:
				activityTitle = "Left group " + getUserGroupHyperLink(activityRootObj)
				break
			case RECOMMENDATION_REMOVED:
				activityTitle = "Removed species name " + feedInstance.activityDescrption
				break
			
			case [RESOURCE_POSTED_ON_GROUP, RESOURCE_REMOVED_FROM_GROUP]:
				activityTitle = feedInstance.activityDescrption  + " " + getUserGroupHyperLink(activityDomainObj)
				break
            case [FEATURED, UNFEATURED]:
                boolean b
                if(activityType == FEATURED){
                    b = true
                }
                else {
                    b = false
                }
                def rootHolder = getDomainObject(feedInstance.rootHolderType, feedInstance.rootHolderId)
                def activityHolder = getDomainObject(feedInstance.activityHolderType, feedInstance.activityHolderId)
                //NOTE: Case for Not IBP group - an actual UserGroup Present
                if(rootHolder != activityHolder) {
                    activityTitle = getDescriptionForFeature(rootHolder, activityHolder , b) + " " + getUserGroupHyperLink(activityHolder)
                }
                else {
                    activityTitle = getDescriptionForFeature(rootHolder, null , b) + " in " + "<font color= black><i>" +grailsApplication.config.speciesPortal.app.siteName + "</i></font>"
                }
                text = feedInstance.activityDescrption
                break
            case SPECIES_UPDATED:
                activityTitle = SPECIES_UPDATED
                break

			default:
				activityTitle = activityType
				break
		}
		
		return [activityTitle:activityTitle, text:text]
	}
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////// Template rendering related //////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	
	def getCommentContext(Comment comment, params){
		String result = ""
		switch (comment.commentHolderType) {
			case Observation.class.getCanonicalName():
				def rootObj = getDomainObject(comment.rootHolderType,comment.rootHolderId)
				if(rootObj.instanceOf(Checklists)){
					def obv = getDomainObject(comment.commentHolderType,comment.commentHolderId)
					result += " on " + getSpeciesNameHtmlFromReco(obv.maxVotedReco, params) + ": Row " + (rootObj.observations.indexOf(obv) + 1) 
				}
				break
			case SpeciesField.class.getCanonicalName():
				SpeciesField sf = getDomainObject(comment.commentHolderType,comment.commentHolderId)
				result += " on species field: " +  sf.field.category + (sf.field.subCategory ? ":" + sf.field.subCategory : "")
				break
			case [SPECIES_SYNONYMS, SPECIES_COMMON_NAMES, SPECIES_MAPS, SPECIES_TAXON_RECORD_NAME]:
				result += " on species field: " + comment.commentHolderType.split("_")[1]
				break
			default:
				break
		}
		return result
	}
	
	def getSpeciesNameHtml(recoVote, params){
		return getSpeciesNameHtmlFromReco(recoVote.recommendation, params)
	}
	
	def getSpeciesNameHtmlFromReco(reco, params){
		if(!reco){
			return ""
		}
		
		def speciesId = reco?.taxonConcept?.findSpeciesId();
		String sb = ""
		if(speciesId != null){
			sb =  '<a href="' + observationService.generateLink("species", "show", [id:speciesId, 'userGroupWebaddress':params?.webaddress]) + '">' + "<i>$reco.name</i>" + "</a>"
            //sb = sb.replaceAll('"|\'','\\\\"')
		}else if(reco.isScientificName){
			sb = "<i>$reco.name</i>"
		}else{
			sb = reco.name
		}
		 return "" + sb
	}
	
	def getUserHyperLink(user, userGroup){
		String sb = '<a href="' +  observationService.generateLink("SUser", "show", ["id": user.id, userGroup:userGroup, 'userGroupWebaddress':userGroup?.webaddress])  + '">' + "<i>$user.name</i>" + "</a>"
        return sb;
        //return sb.replaceAll('"|\'','\\\\"')
	}
	
	def getUserGroupHyperLink(userGroup){
        if(!userGroup){
            return ""
        }
		String sb = '<a href="' + userGroupService.userGroupBasedLink([controller:"userGroup", action:"show", mapping:"userGroup", userGroup:userGroup, userGroupWebaddress:userGroup?.webaddress]) + '">' + "<i>$userGroup.name</i>" + "</a>"
        return sb;
        //return sb.replaceAll('"|\'','\\\\"')
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////// GROUP PULL RELATED ///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////
	
	def addFeedOnGroupResoucePull(resource, UserGroup ug, SUser author, boolean isPost, boolean sendMail = true){
		addFeedOnGroupResoucePull([resource], ug, author, isPost, true, false, sendMail)
	}
	
	def addFeedOnGroupResoucePull(List resources, UserGroup ug, SUser author, boolean isPost, boolean isShowable=true, boolean isBulkPull=false, boolean sendMail=true){
		log.debug "Before Adding feed for resources " + resources.size()
		if(resources.isEmpty()){
			return
		}
		
		log.debug "Adding feed for resources " + resources.size()
		def activityType = isPost ? RESOURCE_POSTED_ON_GROUP : RESOURCE_REMOVED_FROM_GROUP
		Map resCountMap = [:]
		def af 
		resources.each { r->
			def description = getDescriptionForResourcePull(r, isPost)
			af = addActivityFeed(r, ug, author, activityType, description, isShowable, false)
			int oldCount = resCountMap.get(r.class.canonicalName)?:0
			resCountMap.put(r.class.canonicalName, ++oldCount)
			if(!isBulkPull && sendMail){
				observationService.sendNotificationMail(activityType, r, null, null, af)
			}
		}
		if(isBulkPull){
			def description = getDescriptionForBulkResourcePull(isPost, resCountMap)
			af = addActivityFeed(ug, ug, author, activityType, description, true)
            if(sendMail)
			    observationService.sendNotificationMail(activityType, ug, null, null, af)
		} 
		return af
	}
	
	private String getDescriptionForBulkResourcePull(isPost, countMap){
		def desc = isPost ? "Posted" : "Removed"
		int loopVar = 0
		countMap.each { k, v ->
			if(loopVar > 0) desc += " and"
			desc += " " + v + " " + getResourceDisplayName(k, v)
			loopVar++
		}
		desc +=  isPost ? " to group" : " from group"
		return desc
	}
	
	
    private String getDescriptionForResourcePull(r, isPost){
        def desc = isPost ? "Posted" : "Removed"
        desc += " " + getResourceDisplayName(r.class.canonicalName)
        desc +=  isPost ? " to group" : " from group"
        return desc
    }

    /**
     * returns resource name based on count to be displayed on email and msgs
     */
    def getResourceDisplayName(String canonicalName, int count = 0 ){
        String res = ""
        switch(canonicalName){
            case Checklists.class.canonicalName:
            res = "checklist" + ((count > 1) ? "s" : "")
            break
            case Species.class.canonicalName:
            res = "species"
            break
            default:
            res = canonicalName.toLowerCase().split("\\.")[-1] + ((count > 1) ? "s" : "")
            break
        }
        return res 
    }	


    def getResType(r) {
        def desc = ""
        switch(r.class.canonicalName){
            case Checklists.class.canonicalName:
            desc += "checklist"
            break
            default:
            desc += r.class.simpleName.toLowerCase()
            break
        }
        return desc
    }
    def getDescriptionForFeature(r, ug, isFeature)  {
        def desc = isFeature ? "Featured " : "Removed featured "
        String temp = getResType(r)
        desc+= temp
        if(ug == null) {
            return desc
        }
        desc +=  isFeature ? " to group" : " from group"
        return desc


    }
/*
    def getMailSubject(r, isFeature) {
        def desc = ""
        desc += isFeature ? "Featured " : "Removed featured "
        String temp = getResType(r)
        desc+= temp
        return desc
     }*/

}

