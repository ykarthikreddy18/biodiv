<%@ page import="species.Species"%>
<%@ page import="species.TaxonomyDefinition"%>
<%@ page import="species.TaxonomyDefinition.TaxonomyRank"%>
<html>
    <head>
        <g:set var="title" value="Species"/>
        <g:render template="/common/titleTemplate" model="['title':title]"/>
        <r:require modules="observations_create"/>
        <style>
            #addSpecies .add-on {
            height:20px;
            width:98px;
            }
            #addSpecies select.add-on {
            height:30px;
            width:110px;
            }


            #addSpecies .taxonRank {
            min-height:20px;
            width:575px;   
            }
        </style>
    </head>
    <body>

        <div class="observation_create">
            <h1> Add Species </h1>
            <g:hasErrors bean="${speciesInstance}">
            <i class="icon-warning-sign"></i>
            <span class="label label-important"> <g:message
                code="fix.errors.before.proceeding" default="Fix errors" /> </span>
            <%--<g:renderErrors bean="${speciesInstance}" as="list" />--%>
            </g:hasErrors>

            <form id="addSpecies" action="${uGroup.createLink(action:'save', controller:'species', 'userGroup':userGroupInstance, 'userGroupWebaddress':params.webaddress)}" method="POST" class="form-horizontal">

                <div class="span12 super-section" style="clear:both;">

            <div class="section help-block"> 
                <ul>
                    <li>
                    Contributors need to have create rights on the species page in order to add content. If you have not already been allotted rights, please request permission for the taxa of your interest <a href="${uGroup.createLink('controller':'species', 'action':'taxonBrowser')}">here</a>.
                    </li>
                    <li>
                    Please input a species name and validate. If a name is validated and found to already exist on the portal, you will be taken to the species page to add content. If the name is validated and found to be new, you can fill in the taxonomic hierarchy so that the new species page can be created.
                    </li>
                </ul>
           </div>

                    <div class="section">
                    <div class="control-group">
                        <label class="control-label span3" for="name">Add page</label> 
                        <div class="pull-left" style="width:700px;margin-left:20px;">
 
                            <div class="input-prepend">
                                <select id="rank" name="rank" class="add-on">
                                <g:each in="${TaxonomyRank.list().reverse()}" var="rank">
                                    <option value="${rank.ordinal()}" ${(requestParams?requestParams.rank:-1) == rank?'selected':''}>${rank.value()}</option>
                                </g:each>
                            </select>

                            <input id="page" 
                            data-provide="typeahead" type="text" class="taxonRank" style=""
                            name="page" value="${requestParams?requestParams.speciesName:''}" data-rank="${requestParams?requestParams.rank:TaxonomyRank.SPECIES.ordinal()}"
                            placeholder="Add Page" />
                            <input type="hidden" name="canName" id="canName" value=""/>
                            <div id="nameSuggestions" style="display: block;position:relative;"></div>

                        </div>
                            <div id="errorMsg" class="alert hide"></div>
                        </div>
                    </div>  
                    <g:render template="/common/createTaxonRegistryTemplate" model='[requestParams:requestParams, errors:errors]'/>
                    </div>

                </div>   
                <div class="span12 submitButtons">

                    <g:if test="${speciesInstance?.id}">
                    <a href="${uGroup.createLink(controller:params.controller, action:'show', id:speciesInstance.id)}" class="btn"
                        style="float: right; margin-right: 30px;"> Cancel </a>
                    </g:if>
                    <g:else>
                    <a href="${uGroup.createLink(controller:params.controller, action:'list')}" class="btn"
                        style="float: right; margin-right: 30px;"> Cancel </a>
                    </g:else>
                    <a id="validateSpeciesSubmit" class="btn btn-primary"
                        style="float: right; margin-right: 5px;"> Validate</a>


                    <a id="addSpeciesSubmit" class="btn btn-primary"
                        style="float: right; margin-right: 5px;display:none;"> Add Page</a>

                </div>

            </form>
        </div>

    </body>
    <r:script>
    $(document).ready(function() {
        $("#page").autofillNames({
            'appendTo' : '#nameSuggestions',
            'nameFilter':'scientificNames',
            focus: function( event, ui ) {
                $("#canName").val("");
                $("#page").val( ui.item.label.replace(/<.*?>/g,"") );
                $("#nameSuggestions li a").css('border', 0);
                return false;
            },
            select: function( event, ui ) {
                $("#page").val( ui.item.label.replace(/<.*?>/g,"") );
                $("#canName").val( ui.item.value );
                $("#mappedRecoNameForcanName").val(ui.item.label.replace(/<.*?>/g,""));
                return false;
            },open: function(event, ui) {
                //$("#nameSuggestions ul").removeAttr('style').css({'display': 'block','width':'300px'}); 
            }
        });

        var taxonRanks = [];
        <g:each in="${TaxonomyRank.list()}" var="t">
        <g:if test="${t == TaxonomyRank.SUB_GENUS || t == TaxonomyRank.SUB_FAMILY}">
        taxonRanks.push({value:"${t.ordinal()}", text:"${t.value()}", mandatory:false, taxonValue:"${requestParams?requestParams.taxonRegistryNames[t.ordinal()]:''}"});
        </g:if>
        <g:else>
        taxonRanks.push({value:"${t.ordinal()}", text:"${t.value()}", mandatory:true, taxonValue:"${requestParams?requestParams.taxonRegistryNames[t.ordinal()]:''}"});
        </g:else>
        </g:each>

        $('#rank').change(function() {
            $('#page').attr('data-rank', $('#rank').find(':selected').val());
        });

        <g:if test="${requestParams}">
            var $hier = $('#taxonHierachyInput');
            $hier.empty();
            var rank = <%=requestParams?requestParams.rank:0%> ;
            for (var i=0; i<rank; i++) {
                $('<div class="input-prepend"><span class="add-on">'+taxonRanks[i].text+(taxonRanks[i].mandatory?'*':'')+'</span><input data-provide="typeahead" data-rank ="'+taxonRanks[i].value+'" type="text" class="taxonRank" name="taxonRegistry.'+taxonRanks[i].value+'" value="'+taxonRanks[i].taxonValue+'" placeholder="Add '+taxonRanks[i].text+'" /></div>').appendTo($hier);
            }
            if(rank > 0) $('#taxonHierarchyInputForm').show();
            $('#addSpeciesSubmit').show();
        </g:if>

        if($(".taxonRank:not(#page)").length > 0)
            $(".taxonRank:not(#page)").autofillNames();

        $('#validateSpeciesSubmit').click(function() {
            var params = {};
            $("#addSpecies input").each(function(index, ele) {
                if($(ele).val().trim()) params[$(ele).attr('name')] = $(ele).val().trim();
            });
            params['rank'] = $('#rank').find(":selected").val(); 
            //Did u mean species 
            $.ajax({
                url:'/species/validate',
                data:params,
                method:'POST',
                dataType:'json',
                success:function(data) {
                    if(data.success == true) {
                        if(data.id) {
                            window.location.href = '/species/show/'+data.id+'?editMode=true'
                            return;
                            //data.msg += "Did you mean <a href='/species/show/"+data.id+"'>"+data.name+"</a>?"
                        }
                        $('#errorMsg').removeClass('alert-error hide').addClass('alert-info').html(data.msg);
                        //$('#validateSpeciesSubmit').hide()
                        var $ul = $('<ul></ul>');
                        $('#existingHierarchies').empty().append($ul);
                        if(data.taxonRegistry) {
                            $.each(data.taxonRegistry, function(index, value) {
                                var $c = $('<li></li>');
                                $ul.append($c);
                                var $u = $('<ul><b>'+index+'</b></ul>');
                                $c.append($u);
                                $.each(value[0], function(i, v) {
                                    $u.append('<li>'+v.rank+' : '+v.name+'</li>');
                                });
                            });
                        }
                        
                        $('#existingHierarchies').append('<div>If you have a new or a different classification please provide it below.</div>');
                        var $hier = $('#taxonHierachyInput');
                        $hier.empty()
                        for (var i=0; i<data.rank; i++) {
                            var taxonRegistry = data.requestParams? data.requestParams.taxonRegistry:undefined;
                            var taxonValue = (taxonRegistry && taxonRegistry[i]) ?taxonRegistry[i]:taxonRanks[i].taxonValue;
                            $('<div class="input-prepend"><span class="add-on">'+taxonRanks[i].text+(taxonRanks[i].mandatory?'*':'')+'</span><input data-provide="typeahead" data-rank ="'+taxonRanks[i].value+'" type="text" class="taxonRank" name="taxonRegistry.'+taxonRanks[i].value+'" value="'+taxonValue+'" placeholder="Add '+taxonRanks[i].text+'" /></div>').appendTo($hier);
                        }
                        if(data.rank > 0) $('#taxonHierarchyInputForm').show();

                        if($(".taxonRank:not(#page)").length > 0)
                            $(".taxonRank:not(#page)").autofillNames();


                        $('#addSpeciesSubmit').show();
                    } else {
                        if(data.status == 'requirePermission') 
                            window.location.href = '/species/contribute'
                        else 
                            $('#errorMsg').removeClass('alert-info hide').addClass('alert-error').text(data.msg);
                    }
                }, error: function(xhr, status, error) {
                    handleError(xhr, status, error, this.success, function() {
                        var msg = $.parseJSON(xhr.responseText);
                        $(".alertMsg").html(msg.msg).removeClass('alert-success').addClass('alert-error');
                    });
                }
            });
            //get COL hierarchy 
            // get and autofill author contrib hierarchy
        });

        $('#addSpeciesSubmit').click(function() {
            $('#addSpecies').submit();
        });
    });
    </r:script>
</html>
