<%@page import="species.utils.Utils"%>
<%@ page import="org.grails.plugins.google.visualization.data.Cell; org.grails.plugins.google.visualization.util.DateUtil" %>

<div class="entry" style="clear:both;border-style:groove;border-width:6px;color:green;border-radius:10px;">
	<h6>Activity Profile</h6>
	
	<div id="annotatedtimeline_activity" style='width: 947px; height: 180px;'></div>
	<gvisualization:annotatedTimeLine dynamicLoading="${true}" elementId="annotatedtimeline_activity" columns="${activityData.columns}" data="${activityData.data}"/>
	<a style="margin-right: 0px; margin-left: 830px;" href="${uGroup.createLink(controller:'chart')}">View more stats...</a>
</div>

<%--<div style="clear:both;">--%>
<%--		<div>			--%>
<%--			<gvisualization:table elementId="table_user" width="${450}" height="${200}"--%>
<%--				columns="${userData.columns}" data="${userData.htmlData}" showRowNumber="${true}" allowHtml="${true}" />--%>
<%--			<div id="table_user" style="float: left;"></div>--%>
<%--		</div>--%>
<%--		--%>
<%--		<div>			--%>
<%--			<gvisualization:columnCoreChart elementId="columnCoreChart_obv"--%>
<%--				width="${450}" height="${200}"--%>
<%--				vAxis="${new Expando(title: 'Count', titleColor: 'red')}" hAxis="${new Expando(title: (hAxisTitle?:'Species Group'), titleColor: 'red')}"--%>
<%--				columns="${obvData.columns}" data="${obvData.data}"/>--%>
<%--			<div id="columnCoreChart_obv" style="float: left;"></div>--%>
<%--		</div>--%>

<%--		<div>			--%>
<%--			<gvisualization:columnCoreChart elementId="columnCoreChart_species"--%>
<%--				width="${300}" height="${150}"--%>
<%--				vAxis="${new Expando(title: 'Count', titleColor: 'red')}" hAxis="${new Expando(title: (hAxisTitle?:'Species Group'), titleColor: 'red')}"--%>
<%--				columns="${speciesData.columns}" data="${speciesData.data}"/>--%>
<%--			<div id="columnCoreChart_species" style="float: left;"></div>--%>
<%--		</div>--%>
<%--</div>--%>