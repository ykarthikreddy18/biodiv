package speciespage.search

import static groovyx.net.http.ContentType.JSON

import java.text.SimpleDateFormat
import java.util.Date;
import java.util.List
import java.util.Map

import org.apache.solr.client.solrj.SolrQuery
import org.apache.solr.client.solrj.SolrServer
import org.apache.solr.client.solrj.SolrServerException
import org.apache.solr.common.SolrException
import org.apache.solr.common.SolrInputDocument
import org.apache.solr.common.params.SolrParams
import org.apache.solr.common.params.TermsParams

import content.eml.Document;
import org.apache.solr.client.solrj.impl.ConcurrentUpdateSolrServer

class DocumentSearchService extends AbstractSearchService {
	/**
	 *
	 */
	def publishSearchIndex() {
		log.info "Initializing publishing to ufiles search index"
		
		//TODO: change limit
		int limit = Document.count()+1, offset = 0;
		
		def documents;
		def startTime = System.currentTimeMillis()
		while(true) {
			documents = Document.list(max:limit, offset:offset);
			if(!documents) break;
			publishSearchIndex(documents, true);
			documents.clear();
			offset += limit;
            cleanUpGorm();
		}
		
		log.info "Time taken to publish projects search index is ${System.currentTimeMillis()-startTime}(msec)";
	}

	/**
	 *
	 * @param ufiles
	 * @param commit
	 * @return
	 */
	def publishSearchIndex(List<Document> documents, boolean commit) {
		if(!documents) return;
		log.info "Initializing publishing to Documents search index : "+documents.size();

		def fieldsConfig = org.codehaus.groovy.grails.commons.ConfigurationHolder.config.speciesPortal.fields
		def searchFieldsConfig = org.codehaus.groovy.grails.commons.ConfigurationHolder.config.speciesPortal.searchFields

		Collection<SolrInputDocument> docs = new ArrayList<SolrInputDocument>();
		Map names = [:];
		Map docsMap = [:]
		documents.each { document ->
			log.debug "Reading Document : "+document.id;

				SolrInputDocument doc = new SolrInputDocument();
				doc.addField(searchFieldsConfig.ID, document.id.toString());
				doc.addField(searchFieldsConfig.TITLE, document.title);
				doc.addField(searchFieldsConfig.DESCRIPTION, document.notes);
				doc.addField(searchFieldsConfig.TYPE, document.type.value());
				
				if(document.attribution){
					doc.addField(searchFieldsConfig.ATTRIBUTION, document.attribution);
				}
				
				if(document.contributors){
					doc.addField(searchFieldsConfig.CONTRIBUTOR, document.contributors);
				}
				
				document.tags.each { tag ->
					doc.addField(searchFieldsConfig.TAG, tag);
				}
				
				document.userGroups.each { userGroup ->
					doc.addField(searchFieldsConfig.USER_GROUP, userGroup.id);
					doc.addField(searchFieldsConfig.USER_GROUP_WEBADDRESS, userGroup.webaddress);
				}
				docs.add(doc);
			
		}

		//log.debug docs;
        return commitDocs(docs, commit);
	}

}
