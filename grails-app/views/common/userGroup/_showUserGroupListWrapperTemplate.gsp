<%@page import="species.auth.SUser"%>
<%@ page import="species.groups.UserGroup"%>
<div class="filters" style="position: relative;">
	<obv:showGroupFilter model="['hideAdvSearchBar':true]" />
</div>

<div>
	<!-- main_content -->
	<div class="list">

		<div class="observations thumbwrap">
			<div class="observation">
				<div>
					<obv:showObservationFilterMessage
						model="['observationInstanceList':userGroupInstanceList, 'instanceTotal':instanceTotal, 'queryParams':queryParams, 'resultType':'user group']" />
				</div>
				<g:if test="${instanceTotal > 0}">
					<div class="btn-group pull-left" style="z-index: 10">
						<button id="selected_sort" class="btn dropdown-toggle"
							data-toggle="dropdown" href="#" rel="tooltip"
							data-original-title="Sort by">


							<g:if test="${params.sort == 'foundedOn'}">
                                                Latest
                                            </g:if>
							<g:elseif test="${params.sort == 'score'}">
                                                Relevancy
                                            </g:elseif>
							<g:else>
                                                Most Viewed
                                            </g:else>
							<span class="caret"></span>
						</button>
						<ul id="sortFilter" class="dropdown-menu" style="width: auto;">
							<li class="group_option"><a class=" sort_filter_label"
								value="foundedOn"> Latest </a></li>

							<g:if test="${isSearch}">
								<li class="group_option"><a class=" sort_filter_label"
									value="score"> Relevancy </a></li>
							</g:if>
							<g:else>
								<li class="group_option"><a class=" sort_filter_label"
									value="visitCount"> Most Viewed </a></li>
							</g:else>
						</ul>
					</div>


					<uGroup:showUserGroupsList />
				</g:if>
			</div>


		</div>
	</div>

	<!-- main_content end -->
</div>


<!--container end-->
<script text="text/javascript">
$(document).ready(function() {
	window.params.tagsLink = "${uGroup.createLink(controller:'userGroup', action: 'tags')}";

});

$( "#search" ).click(function() {                		
	updateGallery(undefined, ${queryParams?.max}, 0);
	return false;
});
</script>
