<%@page import="species.utils.ImageType"%>
<%@page import="species.participation.Comment"%>
<%@page import="species.groups.UserGroup"%>
<div class="yj-message-container">
	<div class="yj-avatar">
    <%
		def isCommentThread = (feedInstance.subRootHolderType == Comment.class.getCanonicalName() && feedInstance.rootHolderType == UserGroup.class.getCanonicalName()) 
        if(isCommentThread) {
            feedInstance = feedInstance.fetchMainCommentFeed() 
        }
	%>

		<a href="${uGroup.createLink(controller:'SUser', action:'show', id:feedInstance.author.id, userGroup:feedInstance.fetchUserGroup(), 'userGroupWebaddress':feedInstance.fetchUserGroup()?.webaddress)}">
			<img class="small_profile_pic"
				src="${feedInstance.author.profilePicture(ImageType.SMALL)}"
				title="${feedInstance.author.name}" />
		</a>
	</div>
	<feed:showActivityFeedContext
		model="['feedInstance' : feedInstance, 'feedType':feedType, 'feedPermission':feedPermission, feedHomeObject:feedHomeObject, 'isCommentThread':isCommentThread]" />
</div>
