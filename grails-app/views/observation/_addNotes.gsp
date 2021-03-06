<%@ page import="species.utils.Utils"%>
<%@page import="java.util.Arrays"%>


<div class="section" style="position: relative; overflow: visible;">
    <h3>Additional Information </h3>
    <div class="span6 block">
        <!--label for="notes"><g:message code="observation.notes.label" default="Notes" /></label-->
        <h5><label><i
                    class="icon-pencil"></i>Notes <small><g:message code="observation.notes.message" default="Description" /></small></label><br />
            </h5><div class="section-item" style="margin-right: 10px;">
            <!-- g:textArea name="notes" rows="10" value=""
            class="text ui-corner-all" /-->

            <ckeditor:config var="toolbar_editorToolbar">
            [
            [ 'Bold', 'Italic' ]
            ]
            </ckeditor:config>
            <ckeditor:editor name="notes" height="53px" toolbar="editorToolbar">
            ${observationInstance?.notes}
            </ckeditor:editor>
        </div>
    </div>
    <%
    def obvTags = observationInstance?.tags
    if(params.action == 'save' && params?.tags){
    obvTags = Arrays.asList(params.tags)
    }				
    %>

    <div class="span6 block sidebar-section" style="margin:0px 0px 20px -10px;">
        <h5><label><i
                    class="icon-tags"></i>Tags <small><g:message code="observation.tags.message" default="" /></small></label>
        </h5>
        <div class="create_tags section-item" style="clear: both;">
            <ul id="tags" class="obvCreateTags">
                <g:each in="${obvTags}" var="tag">
                <li>${tag}</li>
                </g:each>
            </ul>
        </div>
    </div>



    <sUser:isFBUser>
    <div class="span6 sidebar-section block" style="margin-left:-10px;">
        <div class="create_tags" >
            <label class="checkbox" > <g:checkBox style="margin-left:0px;"
                name="postToFB" />
                Post to Facebook</label>
        </div>
    </div>
    </sUser:isFBUser>



</div>
