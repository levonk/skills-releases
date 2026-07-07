#!/usr/bin/env python3
"""
Conversation Context Capture Helper with tkr Integration

This script helps structure conversation context and optionally creates tkr tickets.
Run with --help for options.
"""

import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path


def format_context(context):
    """Format the context dictionary into markdown"""
    md = "# Conversation Context Handoff\n\n"
    
    # Add tkr reference if present
    if context.get('tkr_ticket'):
        md += "## Ticket Reference\n"
        md += f"- **Ticket ID**: {context['tkr_ticket']}\n"
        if context.get('tkr_parent'):
            md += f"- **Parent Ticket**: {context['tkr_parent']}\n"
        md += "\n"
    
    # Metadata
    md += "## Metadata\n"
    md += f"- **Created**: {context['created']}\n"
    if context.get('session_duration'):
        md += f"- **Session Duration**: {context['session_duration']}\n"
    md += f"- **Primary Goal**: {context['primary_goal']}\n\n"
    
    # Project Overview
    md += "## Project Overview\n"
    md += "### Objective\n"
    md += f"{context['objective']}\n\n"
    md += "### Current Status\n"
    md += f"{context['current_status']}\n\n"
    
    # Key Decisions
    if context.get('key_decisions'):
        md += "## Key Decisions Made\n"
        for decision in context['key_decisions']:
            md += f"- {decision['decision']} - {decision['reason']}\n"
        md += "\n"
    
    # Technical Context
    if context.get('technical_stack') or context.get('important_files'):
        md += "## Technical Context\n"
        if context.get('technical_stack'):
            md += "### Stack/Tools\n"
            for tool in context['technical_stack']:
                md += f"- {tool}\n"
            md += "\n"
        if context.get('important_files'):
            md += "### Important Files\n"
            for file_info in context['important_files']:
                md += f"- `{file_info['path']}` - {file_info['purpose']}\n"
            md += "\n"
        if context.get('environment_notes'):
            md += "### Environment Notes\n"
            md += f"{context['environment_notes']}\n\n"
    
    # Next Steps
    if context.get('next_steps'):
        md += "## Next Steps (Priority Order)\n"
        for i, step in enumerate(context['next_steps'], 1):
            md += f"{i}. {step}\n"
        md += "\n"
    
    # Success Criteria
    if context.get('success_criteria'):
        md += "## Success Criteria\n"
        for criterion in context['success_criteria']:
            md += f"- {criterion['criterion']}: {criterion['verification']}\n"
        md += "\n"
    
    # Open Questions
    if context.get('open_questions'):
        md += "## Open Questions/Blockers\n"
        for question in context['open_questions']:
            md += f"- {question['question']} - {question['impact']}\n"
        md += "\n"
    
    # Important Context
    if context.get('important_context'):
        md += "## Important Context\n"
        md += f"{context['important_context']}\n\n"
    
    # Conversation Summary
    if context.get('conversation_summary'):
        md += "## Conversation Summary\n"
        md += f"{context['conversation_summary']}\n\n"
    
    # Do Not
    if context.get('do_not'):
        md += "## Do Not\n"
        for dont in context['do_not']:
            md += f"- {dont}\n"
        md += "\n"
    
    return md


def check_tkr_available():
    """Check if tkr is available and we're in a project with tickets"""
    # Check if .tickets directory exists
    if not os.path.exists('.tickets'):
        return False, "No .tickets directory found"
    
    # Check if tkr command is available
    try:
        result = subprocess.run(['which', 'tkr'], capture_output=True, text=True)
        if result.returncode != 0:
            return False, "tkr command not found"
    except:
        return False, "tkr command not found"
    
    return True, "tkr available"


def create_tkr_ticket(context, parent_ticket=None):
    """Create a tkr ticket for continuation"""
    try:
        # Prepare ticket title
        title = f"Continue work: {context['primary_goal']}"
        
        # Build tkr command
        cmd = ['tkr', 'create', title]
        
        # Add description
        if context.get('objective'):
            cmd.extend(['-d', context['objective'][:200] + '...' if len(context['objective']) > 200 else context['objective']])
        
        # Add parent if specified
        if parent_ticket:
            cmd.extend(['--parent', parent_ticket])
        
        # Set type to task
        cmd.extend(['-t', 'task'])
        
        # Execute command
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            ticket_id = result.stdout.strip()
            return ticket_id, None
        else:
            return None, result.stderr
            
    except Exception as e:
        return None, str(e)


def capture_interactive():
    """Interactive context capture"""
    print("=== Conversation Context Capture ===\n")
    
    # Check tkr availability
    tkr_available, tkr_status = check_tkr_available()
    if tkr_available:
        print("✓ tkr-enabled project detected")
        use_tkr = input("Create continuation ticket? (Y/n): ").lower() != 'n'
    else:
        print(f"ℹ {tkr_status}")
        use_tkr = False
    
    context = {
        'created': datetime.now().isoformat(),
        'primary_goal': input("Primary goal (one sentence): "),
        'objective': input("Detailed objective: "),
        'current_status': input("Current status/progress: "),
    }
    
    # Check for parent ticket if using tkr
    parent_ticket = None
    if use_tkr:
        parent = input("Parent ticket ID (optional): ").strip()
        if parent:
            parent_ticket = parent
            context['tkr_parent'] = parent
    
    # Optional session duration
    duration = input("Session duration (optional, e.g., '2 hours'): ")
    if duration:
        context['session_duration'] = duration
    
    # Key decisions
    print("\nKey decisions made (press Enter when done):")
    context['key_decisions'] = []
    while True:
        decision = input("Decision: ")
        if not decision:
            break
        reason = input("Reason/Brief context: ")
        context['key_decisions'].append({
            'decision': decision,
            'reason': reason
        })
    
    # Technical stack
    print("\nTechnical stack (press Enter when done):")
    context['technical_stack'] = []
    while True:
        tool = input("Tool/Technology: ")
        if not tool:
            break
        context['technical_stack'].append(tool)
    
    # Important files
    print("\nImportant files (press Enter when done):")
    context['important_files'] = []
    while True:
        path = input("File path: ")
        if not path:
            break
        purpose = input("Purpose: ")
        context['important_files'].append({
            'path': path,
            'purpose': purpose
        })
    
    # Environment notes
    env_notes = input("\nEnvironment notes (optional): ")
    if env_notes:
        context['environment_notes'] = env_notes
    
    # Next steps
    print("\nNext steps (press Enter when done):")
    context['next_steps'] = []
    while True:
        step = input("Next step: ")
        if not step:
            break
        context['next_steps'].append(step)
    
    # Success criteria
    print("\nSuccess criteria (press Enter when done):")
    context['success_criteria'] = []
    while True:
        criterion = input("Criteria: ")
        if not criterion:
            break
        verification = input("How to verify: ")
        context['success_criteria'].append({
            'criterion': criterion,
            'verification': verification
        })
    
    # Open questions
    print("\nOpen questions/blockers (press Enter when done):")
    context['open_questions'] = []
    while True:
        question = input("Question: ")
        if not question:
            break
        impact = input("Impact if unresolved: ")
        context['open_questions'].append({
            'question': question,
            'impact': impact
        })
    
    # Important context
    important = input("\nAny other important context? ")
    if important:
        context['important_context'] = important
    
    # Conversation summary
    summary = input("\nBrief conversation summary: ")
    if summary:
        context['conversation_summary'] = summary
    
    # Do not
    print("\nThings to avoid (press Enter when done):")
    context['do_not'] = []
    while True:
        dont = input("Don't: ")
        if not dont:
            break
        context['do_not'].append(dont)
    
    # Create tkr ticket if requested
    if use_tkr:
        ticket_id, error = create_tkr_ticket(context, parent_ticket)
        if ticket_id:
            context['tkr_ticket'] = ticket_id
            print(f"\n✅ Created continuation ticket: {ticket_id}")
        else:
            print(f"\n❌ Failed to create ticket: {error}")
    
    return context


def save_context(context, output_path=None):
    """Save context to file"""
    if not output_path:
        timestamp = datetime.now().strftime('%Y-%m-%d-%H%M')
        output_path = f"context-{timestamp}.md"
    
    # Ensure .md extension
    if not output_path.endswith('.md'):
        output_path += '.md'
    
    with open(output_path, 'w') as f:
        f.write(format_context(context))
    
    return output_path


def main():
    """Main entry point"""
    if len(sys.argv) > 1 and sys.argv[1] in ['-h', '--help']:
        print("Usage: capture_context.py [options] [output_file]")
        print("Options:")
        print("  --no-tkr    Skip tkr ticket creation")
        print("  --parent ID Specify parent ticket ID")
        print("  output_file Optional path for the context file")
        return
    
    # Parse options
    no_tkr = '--no-tkr' in sys.argv
    parent_id = None
    output_path = None
    
    # Extract arguments
    args = [arg for arg in sys.argv[1:] if not arg.startswith('--')]
    if args:
        output_path = args[0]
    
    if '--parent' in sys.argv:
        idx = sys.argv.index('--parent')
        if idx + 1 < len(sys.argv):
            parent_id = sys.argv[idx + 1]
    
    try:
        context = capture_interactive()
        saved_path = save_context(context, output_path)
        print(f"\n✅ Context saved to: {saved_path}")
        
        if context.get('tkr_ticket'):
            print(f"🎫 Ticket: {context['tkr_ticket']}")
            print(f"   To continue work: tkr start {context['tkr_ticket']}")
            
    except KeyboardInterrupt:
        print("\n\n❌ Context capture cancelled")
    except Exception as e:
        print(f"\n❌ Error: {e}")


if __name__ == "__main__":
    main()
