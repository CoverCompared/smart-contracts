const lineReader = require('line-reader')
const fs = require('fs');

const writer = fs.createWriteStream('airdrop_formatted.txt', { flags: 'a' });

lineReader.eachLine('airdrop_addresses.txt', function(line, last) {
  console.log(`Line from file: ${line}`);
  writer.write(`'${line}',\n`);
  if(last) {
    console.log('Last line printed.');
    const used = process.memoryUsage().heapUsed / 1024 / 1024;
    console.log(`The script uses approximately ${Math.round(used * 100) / 100} MB`);
  }
});