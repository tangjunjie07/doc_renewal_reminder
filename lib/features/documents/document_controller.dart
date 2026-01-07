import 'package:doc_renewal_reminder/features/documents/model/document.dart';
import 'repository/document_repository.dart';

class DocumentController {
  Future<List<Document>> loadDocuments(int memberId) async {
    return DocumentRepository.getByMemberId(memberId);
  }

  Future<Document?> loadDocument(int id) async {
    return DocumentRepository.getById(id);
  }

  Future<void> saveDocument(Document document) async {
    if (document.id == null) {
      await DocumentRepository.insert(document);
    } else {
      await DocumentRepository.update(document);
    }
  }

  Future<void> deleteDocument(int id) async {
    await DocumentRepository.delete(id);
  }
}
