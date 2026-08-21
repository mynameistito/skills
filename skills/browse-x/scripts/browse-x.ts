import { browse, type BrowseResource } from '../lib/browse.js'
import { convertTweet } from '../lib/converter.js'

type Output = { write: (value: string) => void }

class CliError extends Error {
  readonly code: 0 | 1 | 2

  constructor(message: string, code: 0 | 1 | 2) {
    super(message)
    this.code = code
  }
}

const usage = `Usage:
  browse-x.ts <x-status-or-profile-url> [options]
  browse-x.ts status <x-status-url> [options]
  browse-x.ts profile <handle> [options]
  browse-x.ts search <query> [options]
  browse-x.ts followers <handle> [options]
  browse-x.ts following <handle> [options]

Output: --json, --full, --compact, --format markdown|obsidian, --headers
Lists:  --page 1-10, --limit 1-50, --cursor <cursor>, --feed latest|top|media
Status: --thread off|full|conversation|2-100, --userinfo off|author|all,
        --context full|thread, --replies top|recent|off
Other:  --nocache, --help

Fetches public data directly from upstream providers.
`

const fail = (message: string): never => {
  throw new CliError(`browse-x: ${message}`, 2)
}

const setOption = (options: Map<string, string>, name: string, value: string, option: string) => {
  const old = options.get(name)
  if (old !== undefined && old !== value) {
    fail(`${option} was supplied with conflicting values ('${old}' and '${value}')`)
  }
  options.set(name, value)
}

const requireValue = (args: string[], index: number, option: string) => {
  const value = args[index + 1]
  if (!value) fail(`${option} requires a value`)
  return value
}

const validate = (options: Map<string, string>) => {
  const value = (name: string) => options.get(name)
  if (value('format') && !/^(markdown|obsidian|json)$/.test(value('format') as string)) fail('--format must be markdown, obsidian, or json')
  if (value('page') && !/^(?:[1-9]|10)$/.test(value('page') as string)) fail('--page must be an integer from 1 to 10')
  if (value('limit') && !/^(?:[1-9]|[1-4][0-9]|50)$/.test(value('limit') as string)) fail('--limit must be an integer from 1 to 50')
  if (value('feed') && !/^(latest|top|media)$/.test(value('feed') as string)) fail('--feed must be latest, top, or media')
  if (value('thread') && !/^(off|full|conversation|(?:[2-9]|[1-9][0-9]|100))$/.test(value('thread') as string)) fail('--thread must be off, full, conversation, or an integer from 2 to 100')
  if (value('userinfo') && !/^(off|author|all)$/.test(value('userinfo') as string)) fail('--userinfo must be off, author, or all')
  if (value('context') && !/^(full|thread)$/.test(value('context') as string)) fail('--context must be full or thread')
  if (value('replies') && !/^(top|recent|off)$/.test(value('replies') as string)) fail('--replies must be top, recent, or off')
  if (options.has('json') && value('format') && value('format') !== 'json') fail(`--json conflicts with --format ${value('format')}`)
}

const parse = (args: string[]) => {
  if (args.length === 0) throw new CliError(usage, 2)
  if (args[0] === '-h' || args[0] === '--help') throw new CliError(usage, 0)
  let command = ''
  let target = ''
  const first = args[0]
  if (/^(status|profile|search|followers|following)$/.test(first)) {
    command = first
    if (args[1] === '-h' || args[1] === '--help') throw new CliError(usage, 0)
    if (args[1]?.startsWith('-')) fail(`${first} requires a target`)
    target = args[1] ?? fail(`${first} requires a target`)
    args = args.slice(2)
  } else if (/^https?:\/\//.test(first)) {
    target = first
    args = args.slice(1)
  } else fail(`expected a command or public X URL (got '${first}')`)

  const options = new Map<string, string>()
  let headers = false
  for (let index = 0; index < args.length; index += 1) {
    const arg = args[index]
    if (arg === '--json' || arg === '--nocache') options.set(arg.slice(2), 'true')
    else if (arg === '--full') setOption(options, 'full', 'true', '--full/--compact')
    else if (arg === '--compact') setOption(options, 'full', 'false', '--full/--compact')
    else if (arg === '--headers') headers = true
    else if (/^--(format|page|limit|cursor|feed|thread|userinfo|context|replies)$/.test(arg)) {
      const value = requireValue(args, index, arg)
      setOption(options, arg.slice(2), value, arg)
      index += 1
    } else if (arg === '-h' || arg === '--help') throw new CliError(usage, 0)
    else fail(`unknown option '${arg}'`)
  }
  validate(options)
  if (options.has('json')) options.set('format', 'json')
  return { command, target, options, headers }
}

const runLocal = async (parsed: ReturnType<typeof parse>, output: Output) => {
  const { command, target, options } = parsed
  const format = options.get('format')
  let body: string
  let source = 'local'
  const publicStatusUrl = /^https?:\/\/(?:www\.)?(?:x\.com|twitter\.com)\/[^/?#]+\/status\/[0-9]+(?:[/?#]|$)/
  const isStatus = command === 'status' || (command === '' && publicStatusUrl.test(target))

  if (isStatus) {
    const result = await convertTweet({
      url: target,
      format,
      thread: options.get('thread'),
      userinfo: options.get('userinfo'),
      nocache: options.get('nocache'),
      full: options.get('full'),
      context: options.get('context'),
      replies: options.get('replies'),
    })
    body = format === 'json' ? JSON.stringify(result) : result.body
    source = result.source
  } else {
    const resource = (command || 'profile') as BrowseResource
    const handle = command === 'profile'
      ? target
      : target.replace(/^https?:\/\/(?:www\.)?(?:x\.com|twitter\.com)\//, '').split(/[/?#]/)[0]
    const result = await browse({
      resource,
      handle: resource === 'profile' || resource === 'followers' || resource === 'following' ? handle : undefined,
      q: resource === 'search' ? target : undefined,
      feed: options.get('feed'),
      cursor: options.get('cursor'),
      page: options.get('page'),
      limit: options.get('limit'),
      full: options.get('full'),
      format,
      nocache: options.get('nocache'),
    })
    body = format === 'json' ? JSON.stringify(result) : result.markdown
  }

  if (parsed.headers) output.write(`X-Source: ${source}\nX-Cache: local\n\n`)
  output.write(body)
  if (body.length > 0 && !body.endsWith('\n')) output.write('\n')
}

export const run = async (args: string[], output: Output = { write: (value) => process.stdout.write(value) }) => {
  const parsed = parse(args)
  await runLocal(parsed, output)
}

if (process.argv[1]?.replaceAll('\\', '/').endsWith('/browse-x.ts')) {
  run(process.argv.slice(2)).catch((error: unknown) => {
    const cliError = error instanceof CliError ? error : new CliError(`browse-x: ${String(error)}\n`, 1)
    process.stderr.write(cliError.message.endsWith('\n') ? cliError.message : `${cliError.message}\n`)
    process.exitCode = cliError.code
  })
}
