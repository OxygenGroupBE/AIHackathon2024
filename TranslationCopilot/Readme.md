# Translate with Copilot

## Team information  

**Oxygen Group (Belgium)**

- Eric Wauters (waldo): Eric.Wauters@ifacto.be
- Gunter Peeters: Gunter.Peeters@ifacto.be
- Frank Neeckx: fn@astena.be
- Stieven Vermoesen: stv@astena.be

## Problem Statement
When you need to translate a text, it demands extensive knowledge of the language. Also, in a country like Belgium, we have 3 official languages, and there aren't a lot of people that are fluent in all 3 languages.  

## Solution Overview
It happens Copilot is pretty good in understanding and analyzing texts in multiple languages, hence, it should be good in translating texts.  We wanted to introduce this capability into business central.

Name: Translation Copilot
Main features: understanding and translating texts in multiple languages.  It will act like a framework for other functionalities to benefit from it.
We implemented one where it could be really beneficial: Item translations.  In Belgium, we have 3 languages, and we can set up the system to manage the translations of items in the different languages.
The solution is also capable of evaluating a certain translation and suggest a better one.

Some Screenshots:
The translation "test page" to simply test translations from/to any language:

![image-20240222233017304](Readme.assets/image-20240222233017304.png)

It recognizes Thai, and is able to translate it to any language you ask it to.

This is a nice framework to manage item translations.

For example, for item 1908-S, this translation to English is obviously bad:

![image-20240222233155779](Readme.assets/image-20240222233155779.png)

When we "handle Translations with Copilot"

![image-20240222233328455](Readme.assets/image-20240222233328455.png)

The confidence of 0.2 indicates it's a bad translation, and it suggests a better one.  We can simply "select" all of these suggestions, to correct all the translations:

![image-20240222233358930](Readme.assets/image-20240222233358930.png)

## Accomplishments
Better understanding of how copilot handles different languages. Encoding is important.
Better understanding of how capable it is to discover which language is used in a text.

We were able to implement a "translate" feature in Business Central: translate anything to anything.

The mechanics served as an API for managing translations for Items.

## Impact
The system can translate a text in a language you don't need to fully understand.
For Belgians, this is huge ;-).

## Project Continuation
We could extend this project much more, on how to analyze which language is the default used language for example for items of a certain vendor.
I personally see a lot of potential in this, and I hope we can continue this project.

Next step would be: do it in bulk: multiple Items at the same go.

## Value Proposition
Nobody needs to be fluent in all languages.  The system can translate a text in a language you don't need to fully understand.

## Materials: Prototype / Pitch / Images
- GitHub with all the materials: [https://github.com/OxygenGroupBE/AIHackathon2024](https://github.com/OxygenGroupBE/AIHackathon2024)
- GitHub URL to this specific app: [https://github.com/OxygenGroupBE/AIHackathon2024/tree/main/TranslationCopilot](https://github.com/OxygenGroupBE/AIHackathon2024/tree/main/TranslationCopilot)
- Video: [https://github.com/OxygenGroupBE/AIHackathon2024/tree/main/TranslationCopilot/Video](https://github.com/OxygenGroupBE/AIHackathon2024/tree/main/TranslationCopilot/Video)

## Comments
This project is just a small part of all our contributions during the Hackathon.  

Here, you can find the complete overview:  [https://github.com/OxygenGroupBE/AIHackathon2024/blob/main/ReadMe.md](https://github.com/OxygenGroupBE/AIHackathon2024/blob/main/ReadMe.md)