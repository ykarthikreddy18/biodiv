<%@page import="species.utils.Utils"%>
<%@page import="species.Species"%>
<%@page import="species.utils.ImageType"%>
<style>
    <g:if test="${!showDetails}">

    .observation .prop .value {
        margin-left:260px;
    }
    .group_icon_show_wrap{
        float:left;
    }
    </g:if>
    <g:if test="${!showFeatured}">
    li.group_option{
        height:30px;
    }
    li.group_option span{
        padding: 0px;
        float: left;
    }
    .groups_super_div{
        margin-top: -15px;
        margin-right: 10px;
    }
    .groups_div > .dropdown-toggle{
          height: 25px;
    }
    .group_options, .group_option{
          min-width: 110px;
    }
    .save_group_btn{
        float: right;
        margin-right: 11px;
          margin-top: -9px;
    }
    .group_icon_show_wrap{
        border: 1px solid #ccc;
        float: right;
        height: 33px;
        margin-right: 4px;
    }
    .edit_group_btn{
        top: -10px;
        position: relative;
        margin-right: 12px;
    }
    .propagateGrpHab{
        display:none;
        float: right;
        margin-top: -5px;
    }
    
    </g:if>

</style>
<div class="observation_story">
             

                <g:if test="${showFeatured}">
                    <span class="featured_details btn" style="display:none;"><i class="icon-list"></i></span>
                </g:if>
                   
            <g:if test="${showFeatured}">
            <div class="featured_body">
                <div class="featured_title ellipsis"> 
                    <div class="heading">
                    </div>
                </div>
                <g:render template="/common/featureNotesTemplate" model="['instance':datasetInstance, 'featuredNotes':featuredNotes, 'userLanguage': userLanguage]"/>
            </div>
            </g:if>
            <g:else>
        <div class="observation_story_body ${showFeatured?'toggle_story':''}" style=" ${showFeatured?'display:none;':''}">
           <div class="prop">
                <g:if test="${showDetails}">
                <span class="name"><i class="icon-share-alt"></i><g:message code="default.name.label" /></span>
                </g:if>
                <g:else>
                <i class="pull-left icon-share-alt"></i>
                </g:else>
                <div class="value">
                    ${datasetInstance.title}
                </div>
            </div>

            <g:if test="${showDetails}">
                <div class="prop">
                    <g:if test="${showDetails}">
                    <span class="name"><i class="icon-time"></i><g:message code="default.submitted.label" /></span>
                    </g:if>
                    <g:else>
                    <i class="pull-left icon-time"></i>
                    </g:else>
                    <div class="value">
                        <time class="timeago"
                        datetime="${datasetInstance.createdOn.getTime()}"></time>
                    </div>
                </div>

                <div class="prop">
                    <g:if test="${showDetails}">
                    <span class="name"><i class="icon-time"></i><g:message code="default.updated.label" /></span>
                    </g:if>
                    <g:else>
                    <i class="pull-left icon-time"></i>
                    </g:else>
                    <div class="value">
                        <time class="timeago"
                        datetime="${datasetInstance.lastRevised?.getTime()}"></time>
                    </div>
                </div>


                <g:if test="${datasetInstance.externalId}">
                <div class="prop">
                    <g:if test="${showDetails}">
                    <span class="name"><i class="icon-globe"></i><g:message code="default.externalId.label" /></span>
                    </g:if>
                    <g:else>
                    <i class="pull-left icon-globe"></i>
                    </g:else>

                    <div class="value">
                        ${datasetInstance.externalUrl} (${datasetInstance.externalId})
                    </div>
                </div>
                </g:if>

                <g:if test="${datasetInstance.viaId}">
                <div class="prop">
                    <g:if test="${showDetails}">
                    <span class="name"><i class="icon-globe"></i><g:message code="default.viaId.label" /></span>
                    </g:if>
                    <g:else>
                    <i class="pull-left icon-globe"></i>
                    </g:else>

                    <div class="value">
                        ${datasetInstance.viaCode} (${datasetInstance.viaId})
                    </div>
                </div>
                </g:if>


               
           </g:if>

            <g:if test="${datasetInstance.description}">
                <div class="prop">
                    <g:if test="${showDetails}">
                    <span class="name"><i class="icon-info-sign"></i><g:message code="default.notes.label" /></span>
                        <div class="value notes_view linktext">                        
                        <%  def styleVar = 'block';
                            def clickcontentVar = '' 
                        %> 
                        <g:if test="${datasetInstance?.language?.id != userLanguage?.id}">
                                <%  
                                    styleVar = "none"
                                    clickcontentVar = '<a href="javascript:void(0);" class="clickcontent btn btn-mini">'+datasetInstance?.language?.threeLetterCode?.toUpperCase()+'</a>';
                                %>
                            </g:if>
                            
                            ${raw(clickcontentVar)}
                            <div style="display:${styleVar}">${raw(Utils.linkifyYoutubeLink(datasetInstance.description))}</div>
                    
                        </div>
                    </g:if>
                    <g:else>
                    <div class="value notes_view linktext ${showDetails?'':'ellipsis'}">
                        ${raw(Utils.stripHTML(datasetInstance.description))}
                    </div>

                    </g:else>
                </div>
            </g:if>

        <div class="row observation_footer" style="margin-left:0px;">
            <div class="story-footer" style="right:3px;">
                <sUser:showUserTemplate
                model="['userInstance':datasetInstance.author, 'userGroup':userGroup]" />
            </div>
        </div>
        </div>
        </g:else>
    </div>
