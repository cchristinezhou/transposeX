const fs = require('fs');
const path = require('path');
const AdmZip = require('adm-zip');
const { DOMParser, XMLSerializer } = require('@xmldom/xmldom');
const xpath = require('xpath');

// Mapping from step to index (C=0, D=2, etc.)
const stepToIndex = { C: 0, D: 2, E: 4, F: 5, G: 7, A: 9, B: 11 };
const indexToStep = Object.keys(stepToIndex);

// Transpose a single note
function transposeNote(noteElement, interval) {
  const pitch = xpath.select1('pitch', noteElement);
  if (!pitch) return;

  const stepNode = xpath.select1('step', pitch);
  const octaveNode = xpath.select1('octave', pitch);
  let alterNode = xpath.select1('alter', pitch);

  if (!stepNode || !octaveNode) return;

  const step = stepNode.textContent.trim();
  const baseIndex = stepToIndex[step];
  if (baseIndex === undefined) return;

  const alter = alterNode ? parseInt(alterNode.textContent.trim()) : 0;
  const octave = parseInt(octaveNode.textContent.trim());

  const totalIndex = baseIndex + alter;
  const newIndex = totalIndex + interval;

  const newOctave = octave + Math.floor(newIndex / 12);
  const transposedIndex = (newIndex + 12) % 12;

  let closestStep = 'C';
  let bestDiff = 99;

  for (const s of indexToStep) {
    const base = stepToIndex[s];
    const diff = Math.abs(base - transposedIndex);
    if (diff < bestDiff) {
      closestStep = s;
      bestDiff = diff;
    }
  }

  const newBase = stepToIndex[closestStep];
  const newAlter = transposedIndex - newBase;

  stepNode.textContent = closestStep;
  octaveNode.textContent = newOctave.toString();

  if (newAlter === 0) {
    if (alterNode) pitch.removeChild(alterNode);
  } else {
    if (!alterNode) {
      alterNode = pitch.ownerDocument.createElement('alter');
      pitch.insertBefore(alterNode, octaveNode);
    }
    alterNode.textContent = newAlter.toString();
  }
}

// Main function to modify .mxl
async function transposeMXL(inputMXLPath, interval, outputMXLPath) {
  const zip = new AdmZip(inputMXLPath);
  const entries = zip.getEntries();

  const xmlEntry = entries.find(e => e.entryName.endsWith('.xml'));
  if (!xmlEntry) throw new Error('No .xml file found in MXL');

  const xmlData = xmlEntry.getData().toString('utf8');
  const doc = new DOMParser().parseFromString(xmlData, 'text/xml');

  const notes = xpath.select('//note', doc);
  notes.forEach(note => transposeNote(note, interval));

  const updatedXML = new XMLSerializer().serializeToString(doc);
  zip.updateFile(xmlEntry.entryName, Buffer.from(updatedXML, 'utf8'));

  zip.writeZip(outputMXLPath);
}

module.exports = transposeMXL;