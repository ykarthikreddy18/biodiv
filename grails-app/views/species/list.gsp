<%@page import="species.utils.ImageType"%>
<%@page import="species.utils.ImageUtils"%>
<%@page import="species.TaxonomyDefinition.TaxonomyRank"%>
<%@ page import="species.Species"%>
<%@ page import="species.groups.SpeciesGroup"%>
<%@page import="species.utils.Utils"%>
<%@ page import="species.participation.DownloadLog.DownloadType"%>
<%@page import="species.TaxonomyDefinition.TaxonomyRank"%>
<%@ page import="species.Species"%>
<%@ page import="species.Classification"%>

<html>
<head>
<g:set var="canonicalUrl" value="${uGroup.createLink([controller:'species', action:'list', base:Utils.getIBPServerDomain()])}" />
<g:set var="title" value="Species"/>
<g:render template="/common/titleTemplate" model="['title':title, 'description':'', 'canonicalUrl':canonicalUrl, 'imagePath':'']"/>

<r:require modules="species"/>
<r:require modules="species_list" />

</head>
<body>

	<div class="span12">
		<s:showSubmenuTemplate model="['entityName':'Species']" />
                    <uGroup:rightSidebar/>
                    <obv:featured
            model="['controller':params.controller, 'action':'related', 'filterProperty': 'featureBy', 'filterPropertyValue': true, 'id':'featureBy', 'userGroupInstance':userGroupInstance]" />
            <h4>Browse Species</h4>

		<div class="tabbable" style="margin-left:0px;clear:both;">
			<ul class="nav nav-tabs" style="margin-bottom: 0px">
				<li class="active"><a href="#list" data-toggle="tab">Gallery</a>
				</li>
				<li><a href="#taxonBrowser" data-toggle="tab">Taxon Browser</a>
				</li>
				<li><a href="#contribute" data-toggle="tab">Contribute</a>
				</li>

			</ul>

			<div class="tab-content">
				<div id="list" class="tab-pane active">
						<s:speciesFilter></s:speciesFilter>
						<sUser:isAdmin>
							<s:showDownloadAction model="['source':'Species', 'requestObject':request ]" />
						</sUser:isAdmin>
						<uGroup:objectPostToGroupsWrapper model="['objectType':Species.class.canonicalName, canPullResource:canPullResource]"/>
						<div class="list" style="top: 0px;">
							<s:showSpeciesList/>
						</div>
				</div>
                <div id="taxonBrowser" class="tab-pane" style="position:relative">
                    <div class="taxonomyBrowser sidebar_section" data-name="classification" data-speciesid="${speciesInstance?.id}" style="position:relative">
                        <h5>Classifications</h5>	
                <div class="section help-block"> 
                    <ul>
                        <li>
                        Species page content is sourced from researchers and experts who have been authenticated by curators. If you are a researcher and would like to contribute, please expand the taxon browser, select the taxa for which you would like to be a contributor and request permission. Please also follow up by sending an email to  <span class="mailme">${grailsApplication.config.speciesPortal.ibp.supportEmail}</span> with a brief curriculum vitae (CV) or summary of your expertise so that curators can evaluate your application. You will be able to contribute once you have been allotted create/edit rights for the taxa.
                        </li>
                    </ul>
                </div>
                        <div id="taxaHierarchy" style="width:940px;padding:0px">

                            <%
                            def classifications = [];
                            Classification.list().each {
                            classifications.add([it.id, it, null]);
                            }
                            classifications = classifications.sort {return it[1].name};
                            %>

                            <g:render template="/common/taxonBrowserTemplate" model="['classifications':classifications, 'expandAll':false]"/>
                        </div>
                    </div>
                    <g:render template="/species/inviteForContribution"/>
				</div>

				<div id="contribute" class="tab-pane">
                                    <g:render template="contributeTemplate"/>
				</div>
			</div>
		</div>
	</div>
	
	<script type="text/javascript">
		$(document).ready(function(){
			window.params.tagsLink = "${uGroup.createLink(controller:'species', action: 'tags')}";
			$('#speciesGallerySort').change(function(){
				updateGallery(window.location.pathname + window.location.search, ${params.limit?:40}, 0, undefined, false);
				return false;
            });

            // Javascript to enable link to tab
            var url = document.location.toString();
            if (url.match('#')) {
            $('.nav-tabs a[href=#'+url.split('#')[1]+']').tab('show') ;
            } 

            // Change hash for page-reload
            $('.nav-tabs a').on('shown', function (e) {
                window.location.hash = e.target.hash;
            })
        });
        var taxonRanks = [];
        <g:each in="${TaxonomyRank.list()}" var="t">
        taxonRanks.push({value:"${t.ordinal()}", text:"${t.value()}"});
        </g:each>
	</script>

	<r:script>
    $('.list').on('updatedGallery', function(event) {
        $(".grid_view").show();
    });

    $(document).ready(function() {
        var taxonBrowser = $('.taxonomyBrowser').taxonhierarchy({
            expandAll:false
        });	
    });

	</r:script>
    </body>
</html>
