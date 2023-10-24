function output_struct = cleanCorpusDocument(input_struct)

T = table;
T.Pattern = ["\[n\[xxx\]\]", "[a-zA-Z0-9]+[^ ]*- ", "\[x\[.*?\]\]", "\[p\[.*?\]\]"]';  % [a-zA-Z]+[']?[-]?[a-zA-Z]*- 
T.Type = ["personal data", "corrected form", "incorrect form", "places"]';

tokenized_body = tokenizedDocument(input_struct.body, 'RegularExpression', T);


%% Remove tokens from "personal data"
tokenized_body = replaceWords(tokenized_body, "[n[xxx]]", "Lennon");


%% Remove tokens from "corrected form"
tdetails = tokenDetails(tokenized_body);
idx = tdetails.Type == "corrected form";

details = tdetails(idx,:);
old_words = details{:,1};
new_words = erase(old_words, "- ");  % Corrected forms do not eliminate the last space correctly, probably due to not parsing as a "letters" element
new_words = erase(new_words, "-");
tokenized_body = replaceWords(tokenized_body, old_words, new_words);

corrected_forms = new_words;


%% Remove tokens from "incorrect form"
tdetails = tokenDetails(tokenized_body);
idx = tdetails.Type == "incorrect form";

details = tdetails(idx,:);
old_words = details{:,1};
new_words = erase(old_words, ["[x[", "]]"]);
tokenized_body = removeWords(tokenized_body, old_words);

incorrect_forms = new_words;

corrections = [corrected_forms incorrect_forms];


%% Remove tokens from "places"
tdetails = tokenDetails(tokenized_body);
idx = tdetails.Type == "places";

details = tdetails(idx,:);
old_words = details{:,1};
new_words = erase(old_words,["[p[", "]]"]);

tokenized_body = replaceWords(tokenized_body, old_words, new_words);


%% Remove embedded NewLines

tokenized_body = removeWords(tokenized_body, newline);


%% Add corrections and clean text to STRUCT

output_struct = input_struct;
output_struct.corrections = corrections;
output_struct.clean_text = tokenized_body;


end