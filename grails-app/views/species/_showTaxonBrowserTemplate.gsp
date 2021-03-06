<%@page import="species.TaxonomyDefinition.TaxonomyRank"%>
<%@ page import="species.Species"%>
<%@ page import="species.Classification"%>
<%@ page import="species.Species"%>
<%@ page import="species.TaxonomyDefinition"%>
<%@ page import="species.TaxonomyDefinition.TaxonomyRank"%>

<div class="taxonomyBrowser sidebar_section" style="position: relative;" data-name="classification" data-speciesid="${speciesInstance?.id}">
    <h5>Classifications</h5>	

    <div id="taxaHierarchy">
        <g:set var="classifications" value="${speciesInstance.classifications()}" />
        <g:render template="/common/taxonBrowserTemplate" model="['classifications':classifications,'speciesInstance':speciesInstance, 'expandSpecies':true, 'expandAll':false, 'speciesId':speciesInstance.taxonConcept?.id, expandAllIcon:false, isSpeciesContributor:isSpeciesContributor]"/>
    </div>
    <form id="taxonHierarchyForm" class="form-horizontal editableform hide">
        <div class="control-group">
            <div>
                <div class="editable-input">
                    <g:each in="${TaxonomyRank.list()}" var="taxonRank">
                    <g:if test="${taxonRank.ordinal() == speciesInstance.taxonConcept.rank}">
                    <input type="hidden"  data-rank ="${taxonRank.ordinal()}"
                    type="text" name="taxonRegistry.${taxonRank.ordinal()}" 
                    value="${speciesInstance.taxonConcept.name}"
                    placeholder="Add ${taxonRank.value()}" readonly/>
                    </g:if>
                    <g:elseif test="${taxonRank.ordinal() < speciesInstance.taxonConcept.rank}">
                    <div class="input-prepend">
                        <span class="add-on"> ${taxonRank.value()}</span>
                        <input data-provide="typeahead" data-rank ="${taxonRank.ordinal()}"
                        type="text" class="input-block-level taxonRank" name="taxonRegistry.${taxonRank.ordinal()}" value=""
                        placeholder="Add ${taxonRank.value()}" />

                    </div>

                    </g:elseif>
                    </g:each>
                    <input class='classification' type="hidden" name="classification" value="${Classification.findByName(grailsApplication.config.speciesPortal.fields.AUTHOR_CONTRIBUTED_TAXONOMIC_HIERARCHY).id}" readonly/>
                </div>
                <div class="editable-buttons editable-buttons-bottom pull-right">
                    <button type="submit" class="btn btn-primary editable-submit"><i class="icon-ok icon-white"></i>Save</button>
                    <button type="button" class="btn editable-cancel"><i class="icon-remove"></i>Cancel</button>
                </div>
            </div>
        </div> 
    </form>  
    <div class="editable-error-block"></div>
</div>
