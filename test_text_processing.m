clearvars; close all;

%% Input text

% filename = "texts/portrait_dorian_gray_174.txt";
% filename = "texts/the_international_jewish_cook_book.txt";
% filename = "texts/the_whitehouse_cookbook.txt";
% filename = "texts/articulo_revista_EMI.docx";
% filename = "texts/The_Monk_Who_Sold_His_Ferrari.pdf";

filename = "texts/CorpusEscritoCanarias.docx";
text = extractFileText(filename);


%% Preprocess the data

% make text lower case
text = lower(text);
% split text into individual words
text = tokenizedDocument(text);

commonWords = ["ai", "artificial", "intelligence", "matlab", "simulink", "mathworks"];
% remove words that  won’t give us much information
cleanText = removeWords(text, commonWords);
% remove stop words such as "a", "the"
cleanText = removeStopWords(cleanText);
% remove punctuation
cleanText = erasePunctuation(cleanText);

% add part of speech to each word (noun, verb, adjective, etc)
cleanText = addPartOfSpeechDetails(cleanText);
% lemmatize every word (reduce to dictionary term)
cleanText = normalizeWords(cleanText);


tdetails = tokenDetails(text);
head(tdetails)
tdetails = tokenDetails(cleanText);
head(tdetails)

% plot wordcloud again
wordcloud(cleanText)

% plot word clouds side-by-side for comparison
subplot(1, 2, 1), wordcloud(text); title('Raw data');
subplot(1, 2, 2), wordcloud(cleanText); title('Clean data');


%% Text sentiment (using VADER lexicon for positive and negative words)

% compoundScores = vaderSentimentScores(text)


%% Top K Words

rawBoW = bagOfWords(text);
rawTopNwords = topkwords(rawBoW, 10);

cleanBoW = bagOfWords(cleanText);
cleanTopNwords = topkwords(cleanBoW, 10);


%% Top K N-grams of lenght N

bagNgrams = bagOfNgrams(cleanText);
topNgrams = topkngrams(bagNgrams);


%% Generate embeddings out of 16 billion token word embedding

% emb = fastTextWordEmbedding;
% 
% italy = word2vec(emb,"Italy");
% rome = word2vec(emb,"Rome");
% paris = word2vec(emb,"Paris");
% 
% spain = word2vec(emb,"Spain");
% madrid = word2vec(emb,"Madrid");
% 
% word = vec2word(emb,italy - rome + paris)
% word = vec2word(emb,italy - rome + madrid)


%% Perform Word Count for PRIMARY, SECONDARY and BACCALAUREATTE











