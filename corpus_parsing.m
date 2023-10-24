clearvars; close all;

%% Input text

filename = "texts/CorpusEscritoCanarias_Limpio.docx";
corpus = extractFileText(filename);


%% Parse the data into PRIMARIA, SECUNDARIA, BACHILLERATO

corpus_prim = extractBetween(corpus, "****PRIMARIA", "****SECUNDARIA");
corpus_sec  = extractBetween(corpus, "****SECUNDARIA", "****BACHILLERATO");
corpus_bach = extractBetween(corpus, "****BACHILLERATO", "****END");


%% Parse into each school and student

exp_prim = "\[id\[centro(.)*?(\]\])";  % find "[[centro", then as few char as possible using *?, and then find "]]"
exp_sec = "\[id\[centro(.)*?(\]\])";  % find "[[centro", then as few char as possible using *?, and then find "]]"
exp_bach = "\[id\[provincia(.)*?(\]\])";  % find "[[provincia", then as few char as possible using *?, and then find "]]"

[startIndexPrim, endIndexPrim] = regexp(corpus_prim, exp_prim);
n_students_prim = size(startIndexPrim, 2);

[startIndexSec, endIndexSec] = regexp(corpus_sec, exp_sec);
n_students_sec = size(startIndexSec, 2);

[startIndexBach, endIndexBach] = regexp(corpus_bach, exp_bach);
n_students_bach = size(startIndexBach, 2);


%% Parse PRIMARIA (470 students)

for i=1:n_students_prim
    header = extractBetween(corpus_prim, startIndexPrim(i), endIndexPrim(i));
    
    if i== n_students_prim
        body = extractBetween(corpus_prim, endIndexPrim(i)+1, strlength(corpus_prim));
    else
        body = extractBetween(corpus_prim, endIndexPrim(i)+1, startIndexPrim(i+1)-1);
    end
    body = erase(body, newline);
    
    school_id = extractBetween(header, "[id[centro", ";");
    school_id = erase(school_id, ":");
    school_id = erase(school_id, " ");
    school_id = str2double(school_id);
    
    student_id = extractBetween(header, "alumno", "]]");
    student_id = erase(student_id, ":");
    student_id = erase(student_id, " ");
    student_id = str2double(student_id);
    
    data_struct_prim(i).grade = 'PRIMARIA';
    data_struct_prim(i).school_id = school_id;
    data_struct_prim(i).student_id = student_id;
    data_struct_prim(i).header = header;
    data_struct_prim(i).body = body;
end


%% Parse SECUNDARIA (351 students)

for i=1:n_students_sec
    header = extractBetween(corpus_sec, startIndexSec(i), endIndexSec(i));
    
    if i== n_students_sec
        body = extractBetween(corpus_sec, endIndexSec(i)+1, strlength(corpus_sec));
    else
        body = extractBetween(corpus_sec, endIndexSec(i)+1, startIndexSec(i+1)-1);
    end
    body = erase(body, newline);
    
    school_id = extractBetween(header, "[id[centro", ";");
    school_id = erase(school_id, ":");
    school_id = erase(school_id, " ");
    school_id = str2double(school_id);
    
    student_id = extractBetween(header, "alumno", "]]");
    student_id = erase(student_id, ":");
    student_id = erase(student_id, " ");
    student_id = str2double(student_id);
    
    data_struct_sec(i).grade = 'SECUNDARIA';
    data_struct_sec(i).school_id = school_id;
    data_struct_sec(i).student_id = student_id;
    data_struct_sec(i).header = header;
    data_struct_sec(i).body = body;
end


%% Parse BACHILLERATO (331 students)

for i=1:n_students_bach
    header = extractBetween(corpus_bach, startIndexBach(i), endIndexBach(i));
    
    if i== n_students_bach
        body = extractBetween(corpus_bach, endIndexBach(i)+1, strlength(corpus_bach));
    else
        body = extractBetween(corpus_bach, endIndexBach(i)+1, startIndexBach(i+1)-1);
    end
    body = erase(body, newline);
    
    province = extractBetween(header, "[id[centro", ";");
    province = erase(province, ":");
    province = erase(province, " ");
    
    student_id = extractBetween(header, "alumno", "]]");
    student_id = erase(student_id, ":");
    student_id = erase(student_id, " ");
    student_id = str2double(student_id);
    
    data_struct_bach(i).grade = 'BACHILLERATO';
    data_struct_bach(i).province = province;
    data_struct_bach(i).student_id = student_id;
    data_struct_bach(i).header = header;
    data_struct_bach(i).body = body;
end


%% Remove "-" mark from corrected words, and rest of marks from text

tok_docs = tokenizedDocument;  % Creates empty array of documents
prim_docs = tokenizedDocument;
sec_docs = tokenizedDocument;
bach_docs = tokenizedDocument;

data_struct = [];
n_total_students = 0;

prim_bag = bagOfWords;
for i=1:n_students_prim
    output_struct = cleanCorpusDocument(data_struct_prim(i));
    
    n_total_students = n_total_students + 1;
    data_struct{n_total_students} = output_struct;
    tok_docs = [tok_docs output_struct.clean_text];
    prim_docs = [prim_docs output_struct.clean_text];
end
tok_docs = tok_docs(2:end);
prim_docs = prim_docs(2:end);

for i=1:n_students_sec
    output_struct = cleanCorpusDocument(data_struct_sec(i));
    
    n_total_students = n_total_students + 1;
    data_struct{n_total_students} = output_struct;
    tok_docs = [tok_docs output_struct.clean_text];
    sec_docs = [sec_docs output_struct.clean_text];
end
sec_docs = sec_docs(2:end);

for i=1:n_students_bach
    output_struct = cleanCorpusDocument(data_struct_bach(i));
    
    n_total_students = n_total_students + 1;
    data_struct{n_total_students} = output_struct;
    tok_docs = [tok_docs output_struct.clean_text];
    bach_docs = [bach_docs output_struct.clean_text];
end
bach_docs = bach_docs(2:end);


%% Remove incorrect forms from text to allow analysis

% First detect sentence boundaries (BEFORE REMOVING PUNCTUATION)
clean_tokenized_docs = addSentenceDetails(tok_docs);

% Remove punctuation
clean_tokenized_docs = erasePunctuation(clean_tokenized_docs);

% % Remove stop words such as "a", "the"
% cleanText = removeStopWords(cleanText);

% Add part of speech to each word (noun, verb, adjective, etc)
clean_tokenized_docs = addPartOfSpeechDetails(clean_tokenized_docs);

% Stem (Porter Stemmer) every word 
stem_docs = normalizeWords(clean_tokenized_docs);

% Lemmatize every word (reduce to dictionary term)
lemma_docs = normalizeWords(clean_tokenized_docs, 'Style', 'lemma');

bag = bagOfWords(tok_docs);
tbl = topkwords(bag, 30, 'IgnoreCase', true)

clean_bag = bagOfWords(clean_tokenized_docs);
clean_tbl = topkwords(clean_bag, 30, 'IgnoreCase', true)


% Plot word clouds side-by-side for comparison
subplot(1, 2, 1), wordcloud(tok_docs); title('Raw data');
subplot(1, 2, 2), wordcloud(clean_tokenized_docs); title('Clean data');


%% Analysis by Group (Prim, Sec, Bach)

% First detect sentence boundaries (BEFORE REMOVING PUNCTUATION)
clean_prim_docs = addSentenceDetails(prim_docs);
clean_sec_docs = addSentenceDetails(sec_docs);
clean_bach_docs = addSentenceDetails(bach_docs);

% Remove punctuation
clean_prim_docs = erasePunctuation(clean_prim_docs);
clean_sec_docs = erasePunctuation(clean_sec_docs);
clean_bach_docs = erasePunctuation(clean_bach_docs);

% Remove stop words such as "a", "the"
% clean_prim_docs = removeStopWords(clean_prim_docs);
% clean_sec_docs = removeStopWords(clean_sec_docs);
% clean_bach_docs = removeStopWords(clean_bach_docs);

% Add part of speech to each word (noun, verb, adjective, etc)
clean_prim_docs = addPartOfSpeechDetails(clean_prim_docs);
clean_sec_docs = addPartOfSpeechDetails(clean_sec_docs);
clean_bach_docs = addPartOfSpeechDetails(clean_bach_docs);

% Stem (Porter Stemmer) every word 
stem_clean_prim_docs = normalizeWords(clean_prim_docs);
stem_clean_sec_docs = normalizeWords(clean_sec_docs);
stem_clean_bach_docs = normalizeWords(clean_bach_docs);

% Lemmatize every word (reduce to dictionary term)
lemma_clean_prim_docs = normalizeWords(clean_prim_docs, 'Style', 'lemma');
lemma_clean_sec_docs = normalizeWords(clean_sec_docs, 'Style', 'lemma');
lemma_clean_bach_docs = normalizeWords(clean_bach_docs, 'Style', 'lemma');


tdetails = tokenDetails(lemma_clean_prim_docs);
head(tdetails)
tdetails = tokenDetails(lemma_clean_sec_docs);
head(tdetails)
tdetails = tokenDetails(lemma_clean_bach_docs);
head(tdetails)

tbl = context(lemma_clean_prim_docs, "sister");
head(tbl)
tbl = context(lemma_clean_sec_docs, "house");
head(tbl)
tbl = context(lemma_clean_bach_docs, "volcanic");
head(tbl)


% Plot word clouds side-by-side for comparison
figure;
subplot(1, 3, 1), wordcloud(lemma_clean_prim_docs); title('Primaria');
subplot(1, 3, 2), wordcloud(lemma_clean_sec_docs); title('Secundaria');
subplot(1, 3, 3), wordcloud(lemma_clean_bach_docs); title('Bachillerato');


%% Create table of top N words separated by (PRIMARIA, SECUNDARIA, BACHILLERATO)

clean_bag_total = bagOfWords(clean_tokenized_docs);
clean_tbl_total = topkwords(clean_bag_total, 30, 'IgnoreCase', true)

clean_bag_prim = bagOfWords(clean_prim_docs);
clean_tbl_prim = topkwords(clean_bag_prim, 30, 'IgnoreCase', true)

clean_bag_sec = bagOfWords(clean_sec_docs);
clean_tbl_sec = topkwords(clean_bag_sec, 30, 'IgnoreCase', true)

clean_bag_bach = bagOfWords(clean_bach_docs);
clean_tbl_bach = topkwords(clean_bag_bach, 30, 'IgnoreCase', true)


%% Create example to whos difference between Lemma and Stem results

% Plot word clouds side-by-side for comparison (Lemma)
figure;
sgtitle('Lemmatization WordClouds');
subplot(1, 3, 1), wordcloud(lemma_clean_prim_docs); title('Primary');
subplot(1, 3, 2), wordcloud(lemma_clean_sec_docs); title('Secondary');
subplot(1, 3, 3), wordcloud(lemma_clean_bach_docs); title('Baccalaureate');


% Plot word clouds side-by-side for comparison (Stem)
figure;
sgtitle('Stemization WordClouds');
subplot(1, 3, 1), wordcloud(stem_clean_prim_docs); title('Primary');
subplot(1, 3, 2), wordcloud(stem_clean_sec_docs); title('Secondary');
subplot(1, 3, 3), wordcloud(stem_clean_bach_docs); title('Baccalaureate');


%% Create example of Part of Speech indetification in Corpus

tdetails = tokenDetails(clean_tokenized_docs);
head(tdetails)

tdetails = tokenDetails(clean_prim_docs);
head(tdetails)

tdetails = tokenDetails(clean_sec_docs);
head(tdetails)

tdetails = tokenDetails(clean_bach_docs);
head(tdetails)


%% Pretty print some examples

words = ["lennon" "borley"];  % We use "lennon" as a token to replace all personal data concerning names and surnames

print_prim_docs = removeWords(lemma_clean_prim_docs, words);
print_sec_docs = removeWords(lemma_clean_sec_docs, words);
print_bach_docs = removeWords(lemma_clean_bach_docs, words);

% Plot word clouds side-by-side for comparison
figure;
subplot(1, 3, 1), wordcloud(print_prim_docs); title('Primaria');
subplot(1, 3, 2), wordcloud(print_sec_docs); title('Secundaria');
subplot(1, 3, 3), wordcloud(print_bach_docs); title('Bachillerato');


%% Examples using distances

str1 = "family"
str2 = "feimily"

dist_levenshtein = editDistance(str1, str2)
dist_damerau = editDistance(str1, str2, 'SwapCost', 1)
dist_hamming = editDistance(str1, str2, 'InsertCost', Inf, 'DeleteCost', Inf)


%% Examples using TF-IDF

M = tfidf(clean_bag);

aux = M(1151,:);
koko = full(aux);
non_empty = koko > 0;

hist(koko(non_empty),20);
xlim([0 25]);
ylim([0 40]);


%% Shared values in 2 documents

[val1, idx1] = find(M(1151,:));
[val2, idx2] = find(M(1152,:));

shared = intersect(idx1, idx2);


for i = 1:size(shared,2)
    clean_bag.Vocabulary(shared(i))
    [M(1151, shared(i)) M(1152, shared(i))]
end














